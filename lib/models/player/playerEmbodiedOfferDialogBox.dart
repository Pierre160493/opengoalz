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

class PlayerEmbodiedOfferDialogBox extends StatefulWidget {
  final int idPlayer;
  PlayerEmbodiedOfferDialogBox({required this.idPlayer});
  @override
  _PlayerEmbodiedOfferDialogBoxState createState() =>
      _PlayerEmbodiedOfferDialogBoxState();
}

class _PlayerEmbodiedOfferDialogBoxState
    extends State<PlayerEmbodiedOfferDialogBox> {
  late Stream<Player> _playerStream;
  final TextEditingController _bidController = TextEditingController();
  int? _offerAmount;
  late int _offerMin;
  late int _offerMax;
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
            .first);

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
      _offerAmount = null;
      return 'Please enter a valid bid amount';
    }
    _offerAmount = int.tryParse(_bidController.text);
    if (_offerAmount == null) {
      return 'Invalid bid amount';
    }

    if (_offerAmount! < _offerMin) {
      _offerAmount = null;
      return 'Bid amount must be at least $_offerMin';
    }
    if (_offerAmount! > _offerMax) {
      _offerAmount = null;
      return 'Bid amount must be lower than $_offerMax';
    }

    return null;
  }

  Widget _quickChangeButton(String label, double factor, Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          int newValue = (_offerAmount! * factor).round();
          _bidController.text = newValue.toString();
          _offerAmount = newValue;
          if (_offerAmount! < _offerMin) {
            _offerAmount = _offerMin;
          }
          if (_offerAmount! > _offerMax) {
            _offerAmount = _offerMax;
          }
          _bidErrorMessage = _validateBid();
        });
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
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
        _offerMin = (player.expensesTarget * 0.5).toInt();
        _offerMax = _offerMin * 3;

        // Determine border color once
        final Color offerColor =
            _offerAmount == null ? Colors.red : Colors.green;

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return AlertDialog(
              title: Row(
                children: [
                  Text('Offer for embodied player: '),
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
                      /// Offer input
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: offerColor, width: 2.0),
                        ),
                        // leading: Icon(
                        //   Icons.attach_money,
                        //   color: offerColor,
                        // ),
                        title: TextFormField(
                          controller: _bidController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _offerAmount == null
                                ? 'Enter your offer (weekly expenses)'
                                : 'Your weekly expenses offer',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: offerColor,
                                width: 2.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: offerColor,
                                width: 2.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: offerColor,
                                width: 2.0,
                              ),
                            ),
                            errorText: _bidErrorMessage,
                          ),
                        ),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _bidController.text =
                                          _offerMin.toString();
                                      _offerAmount = _offerMin;
                                      _bidErrorMessage = _validateBid();
                                    });
                                  },
                                  child: Text(
                                    NumberFormat('#,###').format(_offerMin),
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: (_offerAmount ?? _offerMin)
                                        .toDouble()
                                        .clamp(_offerMin.toDouble(),
                                            _offerMax.toDouble()),
                                    min: _offerMin.toDouble(),
                                    max: _offerMax.toDouble(),
                                    divisions: (_offerMax - _offerMin) > 0
                                        ? (_offerMax - _offerMin)
                                        : null,
                                    label: NumberFormat('#,###')
                                        .format(_offerAmount ?? _offerMin),
                                    onChanged: (double value) {
                                      setState(() {
                                        int newValue = value.round();
                                        _bidController.text =
                                            newValue.toString();
                                        _offerAmount = newValue;
                                        _bidErrorMessage = _validateBid();
                                      });
                                    },
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _bidController.text =
                                          _offerMax.toString();
                                      _offerAmount = _offerMax;
                                      _bidErrorMessage = _validateBid();
                                    });
                                  },
                                  child: Text(
                                    NumberFormat('#,###').format(_offerMax),
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            /// Quick change buttons (-10%, -1%, +1% and +10%)
                            if (_offerAmount != null)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _quickChangeButton('-10%', 0.9, Colors.green),
                                  _quickChangeButton('-1%', 0.99, Colors.green),
                                  _quickChangeButton('+1%', 1.01, Colors.red),
                                  _quickChangeButton('+10%', 1.1, Colors.red),
                                ],
                              ),
                          ],
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
                    if (_offerAmount != null)
                      TextButton(
                        onPressed: () async {
                          print({
                            'inp_id_player': player.id,
                            'inp_id_club': Provider.of<UserSessionProvider>(
                                    context,
                                    listen: false)
                                .user
                                .selectedClub!
                                .id,
                            'inp_expenses_offered':
                                int.parse(_bidController.text),
                            // Add these if you want to pass comments or date_limit
                            // 'inp_date_limit': ...,
                            // 'inp_number_season': ...,
                            // 'inp_comment_for_player': ...,
                            // 'inp_comment_for_club': ...,
                          });
                          bool isOK = await operationInDB(context, 'FUNCTION',
                              'transfers_handle_new_embodied_player_offer',
                              data: {
                                'inp_id_player': player.id,
                                'inp_id_club': Provider.of<UserSessionProvider>(
                                        context,
                                        listen: false)
                                    .user
                                    .selectedClub!
                                    .id,
                                'inp_expenses_offered':
                                    int.parse(_bidController.text),
                                // Add these if you want to pass comments or date_limit
                                // 'inp_date_limit': ...,
                                // 'inp_number_season': ...,
                                // 'inp_comment_for_player': ...,
                                // 'inp_comment_for_club': ...,
                              });
                          if (isOK) {
                            context.showSnackBar(
                                'Successfully placed an offer on embodied ${player.getPlayerNameString()}',
                                icon: Icon(iconSuccessfulOperation,
                                    color: Colors.green));
                          }

                          Navigator.of(context).pop();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.gavel, color: Colors.green),
                            formSpacer3,
                            Text('Offer '),
                            Text(
                              NumberFormat('#,###')
                                  .format(_offerAmount)
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
