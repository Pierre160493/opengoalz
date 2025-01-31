import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/playerPoaching/player_poaching.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';

class PoachingDialog extends StatefulWidget {
  final PlayerPoaching? playerPoached;
  final Player player;
  final Profile user;
  final String title;
  final String operation;

  PoachingDialog({
    required this.playerPoached,
    required this.player,
    required this.user,
    required this.title,
    required this.operation,
  });

  @override
  _PoachingDialogState createState() => _PoachingDialogState();
}

class _PoachingDialogState extends State<PoachingDialog> {
  String? _notes;
  int _investmentTarget = 50;
  int? _maxPrice;
  String? _investmentTargetError;
  String? _maxPriceError;

  late TextEditingController _investmentTargetController;
  late TextEditingController _notesController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _notes = widget.playerPoached == null ? '' : widget.playerPoached!.notes;
    _investmentTarget = widget.playerPoached == null
        ? 50
        : widget.playerPoached!.investmentTarget;
    _maxPrice =
        widget.playerPoached == null ? null : widget.playerPoached!.maxPrice;

    _investmentTargetController =
        TextEditingController(text: _investmentTarget.toString());
    _notesController = TextEditingController(text: _notes);
    _maxPriceController = TextEditingController(text: _maxPrice?.toString());
  }

  @override
  void dispose() {
    _investmentTargetController.dispose();
    _notesController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(iconPoaching, color: Colors.green, size: iconSizeMedium),
          Text(widget.title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(iconMoney, color: Colors.green),
            title: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Weekly scouting network investment (>= 0)',
                errorText: _investmentTargetError,
              ),
              controller: _investmentTargetController,
              onChanged: (value) {
                int? parsedValue = int.tryParse(value);
                setState(() {
                  if (parsedValue == null || parsedValue < 0) {
                    _investmentTargetError = 'Investment must be >= 0';
                  } else {
                    _investmentTargetError = null;
                    _investmentTarget = parsedValue;
                  }
                });
              },
            ),
            subtitle: Text('Weekly investment from the scouting network',
                style: styleItalicBlueGrey),
            shape: shapePersoRoundedBorder(),
          ),
          ListTile(
            leading: Icon(iconNotesBig,
                color: _notes == null || _notes!.isEmpty
                    ? Colors.orange
                    : Colors.green),
            title: TextField(
              keyboardType: TextInputType.text,
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Notes (optional)',
              ),
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
            ),
            subtitle: Text('Notes about the player (optional)',
                style: styleItalicBlueGrey),
            shape: shapePersoRoundedBorder(),
          ),
          ListTile(
            leading: Icon(iconTransfers,
                color: _maxPrice == null ? Colors.orange : Colors.green),
            title: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: _maxPriceController,
              decoration: InputDecoration(
                hintText:
                    'Max price to bid for the player when he enters auction (optional)',
                errorText: _maxPriceError,
              ),
              onChanged: (value) {
                int? parsedValue = int.tryParse(value);
                setState(() {
                  if (parsedValue != null && parsedValue < 100) {
                    _maxPriceError = 'Max price must be >= 100';
                  } else {
                    _maxPriceError = null;
                    _maxPrice = parsedValue;
                  }
                });
              },
            ),
            subtitle: Text(
                'Max price to bid for the player when he enters auction (optional)',
                style: styleItalicBlueGrey),
            shape: shapePersoRoundedBorder(),
          ),
        ],
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
              child: persoCancelRow,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            if (widget.operation == 'UPDATE')
              TextButton(
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    formSpacer3,
                    Text('Stop poaching'),
                  ],
                ),
                onPressed: () async {
                  bool isOk = await operationInDB(
                      context, 'UPDATE', 'players_poaching',
                      matchCriteria: {
                        'id': widget.player.id,
                      },
                      data: {
                        'investment_target': 0,
                        'notes': _notes,
                        'max_price': null,
                        'to_delete': true,
                      });
                  if (isOk)
                    context.showSnackBar(
                        'The scouting network will stop working on ${widget.player.getFullName()}, no more investment will be made and will be deleted soon');
                  Navigator.of(context).pop();
                },
              ),
            TextButton(
              child: Row(
                children: [
                  Icon(
                    iconSuccessfulOperation,
                    color: Colors.green,
                  ),
                  formSpacer3,
                  Text('Confirm'),
                ],
              ),
              onPressed: (_investmentTargetError != null ||
                      _maxPriceError != null)
                  ? null
                  : () async {
                      if (_investmentTarget < 0) {
                        setState(() {
                          _investmentTargetError = 'Investment must be >= 0';
                        });
                        return;
                      }

                      if (_maxPrice != null && _maxPrice! < 100) {
                        setState(() {
                          _maxPriceError = 'Max price must be >= 100';
                        });
                        return;
                      }

                      if (widget.operation == 'UPDATE') {
                        await operationInDB(
                            context, 'UPDATE', 'players_poaching',
                            matchCriteria: {
                              'id': widget.player.id,
                            },
                            data: {
                              'investment_target': _investmentTarget,
                              'notes': _notes,
                              'max_price': _maxPrice,
                            });
                      } else {
                        await operationInDB(
                            context, 'INSERT', 'players_poaching',
                            data: {
                              'id_club': widget.user.selectedClub!.id,
                              'id_player': widget.player.id,
                              'investment_target': _investmentTarget,
                              if (_notes != null) 'notes': _notes,
                              if (_maxPrice != null) 'max_price': _maxPrice,
                            });
                      }
                      Navigator.of(context).pop();
                    },
            ),
          ],
        ),
      ],
    );
  }
}
