import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/transfers_embodied_players_offer.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

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
  String _commentForPlayer = '';
  String _commentForClub = '';
  TransfersEmbodiedPlayersOffer? _existingClubOffer;
  bool _initializedFromExistingOffer = false;

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
        .switchMap((Player player) {
          return supabase
              .from('transfers_embodied_players_offers')
              .stream(primaryKey: ['id'])
              .eq('id_player', player.id)
              .order('created_at', ascending: true)
              .map((maps) => maps
                  .map((map) => TransfersEmbodiedPlayersOffer.fromMap(map))
                  .toList())
              .map((List<TransfersEmbodiedPlayersOffer> offers) {
                player.offersForEmbodied =
                    offers; // Update the player's offers list
                // Return a tuple (player, offers) for use in build
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
          newValue = newValue.clamp(_offerMin, _offerMax);
          _bidController.text = newValue.toString();
          _offerAmount = newValue;
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

        // If there is an existing offer, initialize controllers/fields only once
        if (_existingClubOffer != null && !_initializedFromExistingOffer) {
          // Schedule the update after build to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _bidController.text =
                    _existingClubOffer!.expensesOffered.toString();
                _offerAmount = _existingClubOffer!.expensesOffered;
                _commentForPlayer = _existingClubOffer!.commentForPlayer ?? '';
                _commentForClub = _existingClubOffer!.commentForClub ?? '';
                _initializedFromExistingOffer = true;
              });
            }
          });
        }

        // Determine border color once
        final Color offerColor =
            _offerAmount == null ? Colors.red : Colors.green;

        return persoAlertDialogWithConstrainedContent(
          title: Row(
            children: [
              Text('Place an offer on '),
              player.getPlayerNameToolTip(context),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_existingClubOffer != null)
                Card(
                  color: Colors.yellow[50],
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(Icons.info, color: Colors.orange),
                    title: Text(
                      'You already have an offer for this player',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly expenses offered: ${NumberFormat('#,###').format(_existingClubOffer!.expensesOffered)}',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                ),

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
                              _bidController.text = _offerMin.toString();
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
                            value: (_offerAmount ?? _offerMin).toDouble().clamp(
                                _offerMin.toDouble(), _offerMax.toDouble()),
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
                                _bidController.text = newValue.toString();
                                _offerAmount = newValue;
                                _bidErrorMessage = _validateBid();
                              });
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _bidController.text = _offerMax.toString();
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

              /// Comment for the user embodying the player
              ListTile(
                leading: Icon(iconUser, color: Colors.green),
                title: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Comment for the user (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _commentForPlayer = value;
                    });
                  },
                ),
                shape: shapePersoRoundedBorder(),
              ),

              /// Comment for the club
              ListTile(
                leading: Icon(iconClub, color: Colors.green),
                title: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Comment for the club (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _commentForClub = value;
                    });
                  },
                ),
                shape: shapePersoRoundedBorder(),
              ),
            ],
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
                        'inp_id_club': Provider.of<UserSessionProvider>(context,
                                listen: false)
                            .user
                            .selectedClub!
                            .id,
                        'inp_expenses_offered': int.parse(_bidController.text),
                        // Add these if you want to pass comments or date_limit
                        // 'inp_date_limit': ...,
                        // 'inp_number_season': ...,
                        'inp_comment_for_player': _commentForPlayer,
                        'inp_comment_for_club': _commentForClub,
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
                            'inp_comment_for_player': _commentForPlayer,
                            'inp_comment_for_club': _commentForClub,
                          });
                      if (isOK) {
                        context.showSnackBar(
                            _existingClubOffer == null
                                ? 'Successfully placed an offer on embodied ${player.getPlayerNameString()}'
                                : 'Successfully updated your offer on embodied ${player.getPlayerNameString()}',
                            icon: Icon(iconSuccessfulOperation,
                                color: Colors.green));
                      }

                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.gavel, color: Colors.green),
                        formSpacer3,
                        Text(_existingClubOffer == null
                            ? 'Place an Offer on '
                            : 'Update Offer on '),
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
  }
}
