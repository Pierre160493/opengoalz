import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/transfer_bid.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/club.dart';
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
  Stream<Player> _playerStream = Stream.empty();
  StreamSubscription<Player>? _playerSubscription;
  Player? _currentPlayer;
  final TextEditingController _bidController = TextEditingController();
  int _minBidAbsolute = 100;
  int? _bidAmount;

  @override
  void initState() {
    super.initState();

    _playerStream = supabase

        /// Fetch the player
        .from('players')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idPlayer)
        .map((maps) => maps.map((map) => Player.fromMap(map)).first)

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
                player.transferBids.clear();
                player.transferBids.addAll(transfersBids);
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

    _playerSubscription = _playerStream.listen((player) {
      setState(() {
        _currentPlayer = player;
      });
    });

    _bidController.addListener(_validateBid);
    _validateBid();
  }

  @override
  void dispose() {
    _bidController.removeListener(_validateBid);
    _bidController.dispose();
    _playerSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  void _validateBid() {
    setState(() {
      _bidAmount = int.tryParse(_bidController.text);
      if (_bidAmount == null || _currentPlayer == null) {
        return;
      }

      final int availableCash =
          Provider.of<SessionProvider>(context, listen: false)
              .user!
              .selectedClub!
              .cash;
      final int? currentHighestBid = _currentPlayer!.transferBids.length == 1
          ? null
          : _currentPlayer!.transferBids.last.amount;
      final int minimumBid = currentHighestBid == null
          ? _minBidAbsolute
          : max(_minBidAbsolute, (currentHighestBid * 1.01).ceil());

      if (_bidAmount! > availableCash) {
        _bidAmount = null;
      } else if (_bidAmount! < minimumBid) {
        _bidAmount = null;
      } else if (_bidAmount! < currentHighestBid!) {
        _bidAmount = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPlayer == null) {
      return Center(child: CircularProgressIndicator());
    }

    final Player player = _currentPlayer!;
    final int? currentHighestBid = player.idClub == null
        ? player.transferBids.length == 0
            ? null
            : player.transferBids.last.amount
        : player.transferBids.length == 1
            ? null
            : player.transferBids.last.amount;
    final int minimumBid = currentHighestBid == null
        ? _minBidAbsolute
        : max(_minBidAbsolute, (currentHighestBid * 1.01).ceil());

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
                Provider.of<SessionProvider>(context, listen: false)
                    .user!
                    .selectedClub!
                    .getCashListTile(),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.green, width: 2.0),
                  ),
                  leading: Icon(
                    Icons.gavel,
                    color: Colors.green,
                  ),
                  title: Row(
                    children: [
                      Text(currentHighestBid == null
                          ? 'No bids yet'
                          : 'Current highest bid: '),
                      if (currentHighestBid != null)
                        Text(
                            NumberFormat('#,###')
                                .format(currentHighestBid)
                                .replaceAll(',', ' '),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: currentHighestBid == null
                      ? null
                      // : Text('By: ${player.transferBids.last.nameClub}'),
                      : player.transferBids.last.club!
                          .getClubNameClickable(context),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                        color: _bidAmount == null ? Colors.red : Colors.green,
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
                      errorText:
                          _bidAmount == null ? 'Invalid bid amount' : null,
                    ),
                  ),
                  subtitle: Tooltip(
                    message: 'Click to bid the minimum amount',
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _bidController.text = minimumBid.toString();
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
                                    .format(minimumBid)
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
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    formSpacer3,
                    Text('Cancel'),
                  ],
                ),
              ),
              if (_bidAmount != null)
                TextButton(
                  onPressed: () async {
                    print({
                      'inp_id_player': player.id,
                      'inp_id_club_bidder':
                          Provider.of<SessionProvider>(context, listen: false)
                              .user!
                              .selectedClub!
                              .id,
                      'inp_amount': int.parse(_bidController.text)
                    });

                    /// Try to insert the bid
                    bool isOK = await operationInDB(
                        context, 'FUNCTION', 'transfers_handle_new_bid',
                        data: {
                          'inp_id_player': player.id,
                          'inp_id_club_bidder': Provider.of<SessionProvider>(
                                  context,
                                  listen: false)
                              .user!
                              .selectedClub!
                              .id,
                          'inp_amount': int.parse(_bidController.text)
                        }); // Use index to modify id
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
    });
  }
}
