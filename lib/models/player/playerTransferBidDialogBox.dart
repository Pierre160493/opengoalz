import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/clubCashListTile.dart';
import 'package:opengoalz/models/player/playerCardTransferListTile.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

class PlayerTransferBidDialogBox extends StatefulWidget {
  final int idPlayer;
  PlayerTransferBidDialogBox({required this.idPlayer});
  @override
  _PlayerTransferBidDialogBoxState createState() =>
      _PlayerTransferBidDialogBoxState();
}

class _PlayerTransferBidDialogBoxState
    extends State<PlayerTransferBidDialogBox> {
  late Stream<Player> _playerStream;
  final TextEditingController _bidController = TextEditingController();
  int? _bidAmount;
  int? _bidMinimum;
  String? _bidErrorMessage;

  @override
  void initState() {
    super.initState();

    _playerStream = supabase

        /// Fetch the player
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idPlayer)
        .map((maps) => maps
            .map((map) => Player.fromMap(map,
                Provider.of<UserSessionProvider>(context, listen: false).user))
            .first)

        /// Fetch its transfers bids
        .switchMap((Player player) {
          return supabase
              .from('transfers_bids')
              .stream(primaryKey: ['id'])
              .eq('id_player', player.id)
              .order('created_at', ascending: true)
              .map((maps) =>
                  maps.map((map) => TransferBid.fromMap(map)).toList())
              .map((List<TransferBid> transfersBids) {
                if (transfersBids.isEmpty) {
                  _bidMinimum = player.transferPrice!.abs();
                } else {
                  _bidMinimum = (transfersBids.last.amount * 1.01).ceil();
                  player.transferBids.clear();
                  player.transferBids.addAll(transfersBids);
                }
                _bidController.text = _bidMinimum.toString();
                return player;
              });
        })

        /// Fetch the player's club and the last club that bid on him (if any)
        .switchMap((Player player) {
          final List<int> clubIds = [];
          if (player.idClub != null) {
            clubIds.add(player.idClub!);
          }
          if (player.transferBids.isNotEmpty) {
            clubIds.add(player.transferBids.last.idClub);
          }
          if (clubIds.isEmpty) {
            return Stream.value(player);
          }
          return supabase
              .from('clubs')
              .stream(primaryKey: ['id'])
              .inFilter('id', clubIds)
              .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
              .map((List<Club> clubs) {
                if (player.idClub != null) {
                  player.club =
                      clubs.firstWhere((club) => club.id == player.idClub);
                }
                if (player.transferBids.isNotEmpty) {
                  final Club club = clubs.firstWhere(
                      (club) => club.id == player.transferBids.last.idClub);
                  player.transferBids.last.club = club;
                }
                return player;
              });
        });

    _bidController.addListener(() {
      setState(() {
        _bidErrorMessage = _validateBid();
      });
    });
    _bidErrorMessage = _validateBid();
  }

  @override
  void dispose() {
    _bidController.removeListener(_validateBid);
    _bidController.dispose();
    super.dispose();
  }

  String? _validateBid() {
    if (_bidController.text.isEmpty) {
      _bidAmount = null;
      return 'Please enter a valid bid amount';
    }
    _bidAmount = int.tryParse(_bidController.text);
    if (_bidAmount == null) {
      return 'Invalid bid amount';
    }

    if (_bidAmount! < _bidMinimum!) {
      _bidAmount = null;
      return 'Bid amount must be at least $_bidMinimum';
    }

    if (_bidAmount! >
        Provider.of<UserSessionProvider>(context, listen: false)
            .user
            .selectedClub!
            .clubData
            .cash) {
      _bidAmount = null;
      return 'Insufficient funds to place a bid of $_bidAmount';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Player>(
      stream: _playerStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingCircularAndText('Loading player data...');
        } else if (snapshot.hasError) {
          return Center(child: Text('ERROR: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No player data available'));
        }

        final Player player = snapshot.data!;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              title: Row(
                children: [
                  Text('Transfer Bid for '),
                  player.getPlayerNameToolTip(context),
                ],
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                    minWidth: min(constraints.maxWidth * 0.8, maxWidth * 0.8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      getClubCashListTile(
                          context,
                          Provider.of<UserSessionProvider>(context,
                                  listen: false)
                              .user
                              .selectedClub!),
                      PlayerCardTransferWidget(player: player),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(
                              color: _bidAmount == null
                                  ? Colors.red
                                  : Colors.green,
                              width: 2.0),
                        ),
                        leading: Icon(
                          Icons.attach_money,
                          color: Colors.blue,
                        ),
                        title: TextFormField(
                          controller: _bidController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter your bid amount',
                            border: OutlineInputBorder(),
                            errorText: _bidErrorMessage,
                          ),
                        ),
                        subtitle: Tooltip(
                          message: 'Click to bid the minimum amount',
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _bidController.text = _bidMinimum.toString();
                              });
                            },
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Minimum bid: ',
                                      style: styleItalicBlueGrey.copyWith(
                                        decoration: TextDecoration.underline,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      NumberFormat('#,###')
                                          .format(_bidMinimum)
                                          .replaceAll(',', ' '),
                                      style: styleItalicBlueGrey.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: persoCancelRow,
                    ),
                    if (_bidAmount != null)
                      TextButton(
                        onPressed: () async {
                          print({
                            'inp_id_player': player.id,
                            'inp_id_club_bidder':
                                Provider.of<UserSessionProvider>(context,
                                        listen: false)
                                    .user
                                    .selectedClub!
                                    .id,
                            'inp_amount': int.parse(_bidController.text)
                          });
                          bool isOK = await operationInDB(
                              context, 'FUNCTION', 'transfers_handle_new_bid',
                              data: {
                                'inp_id_player': player.id,
                                'inp_id_club_bidder':
                                    Provider.of<UserSessionProvider>(context,
                                            listen: false)
                                        .user
                                        .selectedClub!
                                        .id,
                                'inp_amount': int.parse(_bidController.text)
                              });
                          if (isOK) {
                            context.showSnackBar(
                                'Successfully placed bid on ${player.getPlayerNameString()}',
                                icon: Icon(iconSuccessfulOperation,
                                    color: Colors.green));
                          }

                          Navigator.of(context).pop();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.gavel, color: Colors.green),
                            formSpacer3,
                            Text('Bid '),
                            Text(
                              NumberFormat('#,###')
                                  .format(_bidAmount)
                                  .replaceAll(',', ' '),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(' on '),
                            player.getPlayerNameToolTip(context)
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
