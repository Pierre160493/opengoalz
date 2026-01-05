import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/scouts_page/scouts_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/tickingTime.dart';

class PlayerPoachingIconButton extends StatefulWidget {
  final Player player;
  final Profile user;

  PlayerPoachingIconButton({required this.player, required this.user});

  @override
  _PlayerPoachingIconButtonState createState() =>
      _PlayerPoachingIconButtonState();
}

class _PlayerPoachingIconButtonState extends State<PlayerPoachingIconButton> {
  String? _notes;
  DateTime? _dateDelete;
  late int _investmentTarget;
  int? _maxPrice;
  String? _maxPriceError;
  late TextEditingController _notesController;
  late TextEditingController _investmentTargetController;
  late TextEditingController _maxPriceController;

  @override
  void initState() {
    super.initState();
    _notes = widget.player.poaching?.notes;
    _dateDelete = widget.player.poaching?.dateDelete;
    if (widget.player.poaching?.investmentTarget != null) {
      _investmentTarget = widget.player.poaching!.investmentTarget;
    } else {
      _investmentTarget = 100;
    }
    _maxPrice = widget.player.poaching?.maxPrice ?? 100;
    _notesController = TextEditingController(text: _notes);
    _investmentTargetController =
        TextEditingController(text: _investmentTarget.toString());
    _maxPriceController = TextEditingController(text: _maxPrice.toString());
  }

  void _resetNotes(StateSetter setState) {
    setState(() {
      _notes = widget.player.poaching?.notes;
      _notesController.text = _notes ?? '';
    });
  }

  void _resetDate(StateSetter setState) {
    setState(() {
      _dateDelete = widget.player.poaching?.dateDelete;
    });
  }

  void _resetInvestmentTarget(StateSetter setState) {
    setState(() {
      _investmentTarget = widget.player.poaching?.investmentTarget ?? 50;
      _investmentTargetController.text = _investmentTarget.toString();
    });
  }

  void _resetMaxPrice(StateSetter setState) {
    setState(() {
      _maxPrice = widget.player.poaching?.maxPrice ?? 100;
      _maxPriceController.text = _maxPrice.toString();
      _maxPriceError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// If the player is already in the club, do not show the poaching button
    // if (widget.player.isPartOfClubOfCurrentUser) {
    //   return Container();
    // }
    return IconButton(
      tooltip: widget.player.poaching == null
          ? 'Poach this player'
          : 'Open poaching settings',
      icon: Icon(iconPoaching,
          color:
              widget.player.poaching == null ? Colors.blueGrey : Colors.orange),
      iconSize: iconSizeSmall,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () async {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(widget.player.poaching == null
                      ? 'Set ${widget.player.getFullName()} in the list of poached players'
                      : 'Poached player: ${widget.player.getFullName()}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(setState),
                      _buildDatePicker(setState),
                      _buildInvestmentTargetField(setState),
                      _buildMaxPriceField(setState),
                    ],
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _cancelButton(),
                        _openPoachingPageButton(),
                        widget.player.poaching == null
                            ? _setAsPoachedButton()
                            : _notes == widget.player.poaching?.notes &&
                                    _dateDelete ==
                                        widget.player.poaching?.dateDelete &&
                                    _investmentTarget ==
                                        widget.player.poaching
                                            ?.investmentTarget &&
                                    _maxPrice ==
                                        widget.player.poaching?.maxPrice
                                ? _deleteButton()
                                : _updateButton(),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(StateSetter setState) {
    return ListTile(
      leading: Icon(iconNotesBig, color: Colors.green),
      title: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Enter notes on the player',
          suffixIcon: _notes != widget.player.poaching?.notes
              ? IconButton(
                  tooltip: 'Reset notes',
                  icon: Icon(Icons.clear, color: Colors.red),
                  onPressed: () => _resetNotes(setState),
                )
              : null,
        ),
        controller: _notesController,
        onChanged: (value) {
          setState(() {
            _notes = value;
          });
        },
      ),
      subtitle: Text('Notes on the poached player (optional)',
          style: styleItalicBlueGrey),
      shape: shapePersoRoundedBorder(
          _notes == null ? Colors.orange : Colors.green),
    );
  }

  Widget _buildDatePicker(StateSetter setState) {
    return ListTile(
      leading: Icon(Icons.auto_delete, color: Colors.green),
      title: Row(
        children: [
          Expanded(
            child: TextButton(
              child: Text(_dateDelete != null
                  ? formatDate(_dateDelete!.toLocal())
                  : 'Pick a date to automatically remove the player (optional)'),
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() {
                    _dateDelete = picked;
                  });
                }
              },
            ),
          ),
          if (_dateDelete != widget.player.poaching?.dateDelete)
            IconButton(
              tooltip: 'Reset date',
              icon: Icon(Icons.clear, color: Colors.red),
              onPressed: () => _resetDate(setState),
            ),
          if (_dateDelete != null)
            IconButton(
              tooltip: 'Set to null',
              icon: Icon(Icons.do_not_disturb, color: Colors.red),
              onPressed: () {
                setState(() {
                  _dateDelete = null;
                });
              },
            ),
        ],
      ),
      subtitle: Column(
        children: [
          Text(
              'Date when the player will be removed from the list of poached players (optional)',
              style: styleItalicBlueGrey),
          _dateDelete == null ? Container() : tickingTimeWidget(_dateDelete!),
        ],
      ),
      shape: shapePersoRoundedBorder(
          _dateDelete == null ? Colors.orange : Colors.green),
    );
  }

  Widget _buildInvestmentTargetField(StateSetter setState) {
    return ListTile(
      leading: Icon(iconMoney, color: Colors.green),
      title: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Weekly scouting network investment (>= 0)',
          suffixIcon:
              _investmentTarget != widget.player.poaching?.investmentTarget
                  ? IconButton(
                      tooltip: 'Reset investment target',
                      icon: Icon(Icons.clear, color: Colors.red),
                      onPressed: () => _resetInvestmentTarget(setState),
                    )
                  : null,
        ),
        controller: _investmentTargetController,
        onChanged: (value) {
          setState(() {
            _investmentTarget = int.tryParse(value) ?? 50;
          });
        },
      ),
      subtitle: Text('Weekly investment from the scouting network',
          style: styleItalicBlueGrey),
      shape: shapePersoRoundedBorder(Colors.green),
    );
  }

  Widget _buildMaxPriceField(StateSetter setState) {
    return ListTile(
      leading: Icon(iconTransfers, color: Colors.green),
      title: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText:
              'Max price to bid for the player when he enters auction (optional)',
          errorText: _maxPriceError,
          suffixIcon: _maxPrice != widget.player.poaching?.maxPrice
              ? IconButton(
                  tooltip: 'Reset max price',
                  icon: Icon(Icons.clear, color: Colors.red),
                  onPressed: () => _resetMaxPrice(setState),
                )
              : null,
        ),
        controller: _maxPriceController,
        onChanged: (value) {
          setState(() {
            _maxPrice = int.tryParse(value);
            if (_maxPrice != null && _maxPrice! < 100) {
              _maxPriceError = 'Max price must be >= 100';
            } else {
              _maxPriceError = null;
            }
          });
        },
      ),
      subtitle: Text(
          'Max price to bid for the player when he enters auction (optional)',
          style: styleItalicBlueGrey),
      shape: shapePersoRoundedBorder(
          _maxPrice == null ? Colors.orange : Colors.green),
    );
  }

  Widget _cancelButton() {
    return TextButton(
      child: persoCancelRow(),
      onPressed: () {
        Navigator.of(context).pop(false);
      },
    );
  }

  Widget _openPoachingPageButton() {
    return TextButton(
      child: Row(
        children: [
          Icon(iconPoaching, color: Colors.green),
          formSpacer3,
          Text('Open poaching page'),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScoutsPage(initialTab: ScoutsPageTab.poachedPlayers),
          ),
        );
      },
    );
  }

  Widget _setAsPoachedButton() {
    return TextButton(
      child: Row(
        children: [
          Icon(iconSuccessfulOperation, color: Colors.green),
          formSpacer3,
          Text('Set as poached'),
        ],
      ),
      onPressed: () async {
        if (_maxPrice != null && _maxPrice! < 100) {
          setState(() {
            _maxPriceError = 'Max price must be >= 100';
          });
          return;
        }

        await operationInDB(context, 'INSERT', 'players_poaching',
            data: {
              'id_club': widget.user.selectedClub!.id,
              'id_player': widget.player.id,
              if (_notes != null) 'notes': _notes,
              if (_dateDelete != null)
                'date_delete': _dateDelete!.toIso8601String(),
              'investment_target': _investmentTarget,
              'max_price': _maxPrice,
            },
            messageSuccess:
                'Successfully set ${widget.player.getFullName()} in the list of poached players');

        Navigator.of(context).pop();
      },
    );
  }

  Widget _deleteButton() {
    return TextButton(
      child: Row(
        children: [
          Icon(iconCancel, color: Colors.red),
          formSpacer3,
          Text('Remove from poached'),
        ],
      ),
      onPressed: () async {
        await operationInDB(context, 'UPDATE', 'players_poaching',
            data: {'to_delete': true, 'investment_target': 0},
            matchCriteria: {'id': widget.player.poaching!.id},
            messageSuccess:
                'Successfully removed ${widget.player.getFullName()} from the list of poached players');

        Navigator.of(context).pop();
      },
    );
  }

  Widget _updateButton() {
    return TextButton(
      child: Row(
        children: [
          Icon(Icons.sync, color: Colors.green),
          formSpacer3,
          Text('Update'),
        ],
      ),
      onPressed: () async {
        if (_maxPrice != null && _maxPrice! < 100) {
          setState(() {
            _maxPriceError = 'Max price must be >= 100';
          });
          return;
        }

        await operationInDB(context, 'UPDATE', 'players_poaching',
            data: {
              'id': widget.player.poaching!.id,
              if (_notes != widget.player.poaching?.notes) 'notes': _notes,
              if (_dateDelete != widget.player.poaching?.dateDelete)
                'date_delete':
                    _dateDelete != null ? _dateDelete!.toIso8601String() : null,
              if (_investmentTarget != widget.player.poaching?.investmentTarget)
                'investment_target': _investmentTarget,
              if (_maxPrice != widget.player.poaching?.maxPrice)
                'max_price': _maxPrice,
            },
            matchCriteria: {'id': widget.player.poaching!.id},
            messageSuccess:
                'Successfully updated ${widget.player.getFullName()} in the list of poached players');

        Navigator.of(context).pop();
      },
    );
  }
}
