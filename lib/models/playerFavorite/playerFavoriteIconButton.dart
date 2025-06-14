import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/scouts_page/scouts_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/tickingTime.dart';

class PlayerFavoriteIconButton extends StatefulWidget {
  final Player player;
  final Profile user;

  PlayerFavoriteIconButton({required this.player, required this.user});

  @override
  _PlayerFavoriteIconButtonState createState() =>
      _PlayerFavoriteIconButtonState();
}

class _PlayerFavoriteIconButtonState extends State<PlayerFavoriteIconButton> {
  String? _notes;
  DateTime? _dateDelete;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notes = widget.player.favorite?.notes;
    _dateDelete = widget.player.favorite?.dateDelete;
    _notesController = TextEditingController(text: _notes);
  }

  void _resetNotes(StateSetter setState) {
    setState(() {
      _notes = widget.player.favorite?.notes;
      _notesController.text = _notes ?? '';
    });
  }

  void _resetDate(StateSetter setState) {
    setState(() {
      _dateDelete = widget.player.favorite?.dateDelete;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip:
          widget.player.favorite == null ? 'Set as favorite' : 'Open favorite',
      icon: Icon(iconFavorite,
          color: widget.player.favorite == null ? Colors.blueGrey : Colors.red),
      iconSize: iconSizeSmall,
      onPressed: () async {
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(widget.player.favorite == null
                      ? 'Set ${widget.player.getFullName()} in the list of favorite players'
                      : 'favorite player: ${widget.player.getFullName()}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNotesField(setState),
                      _buildDatePicker(setState),
                    ],
                  ),
                  actions: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        _cancelButton(),
                        _openFavoritePageButton(),
                        widget.player.favorite == null
                            ? _setAsFavoriteButton()
                            : _notes == widget.player.favorite?.notes &&
                                    _dateDelete ==
                                        widget.player.favorite?.dateDelete
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

  Widget _buildNotesField(StateSetter setState) {
    return ListTile(
      leading: Icon(iconNotesBig, color: Colors.green),
      title: TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: 'Enter notes on the player',
          suffixIcon: _notes != widget.player.favorite?.notes
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
      subtitle: Text('Notes on the favorite player (optional)',
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
          if (_dateDelete != widget.player.favorite?.dateDelete)
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
              'Date when the player will be removed from the list of favorite players (optional)',
              style: styleItalicBlueGrey),
          _dateDelete == null ? Container() : tickingTimeWidget(_dateDelete!),
        ],
      ),
      shape: shapePersoRoundedBorder(
          _dateDelete == null ? Colors.orange : Colors.green),
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

  Widget _openFavoritePageButton() {
    return TextButton(
      child: Row(
        children: [
          Icon(iconFavorite, color: Colors.green),
          formSpacer3,
          Text('Open favorite page'),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ScoutsPage(initialTab: ScoutsPageTab.followedPlayers),
          ),
        );
      },
    );
  }

  Widget _setAsFavoriteButton() {
    return TextButton(
      child: Row(
        children: [
          Icon(iconSuccessfulOperation, color: Colors.green),
          formSpacer3,
          Text('Set as favorite'),
        ],
      ),
      onPressed: () async {
        await operationInDB(context, 'INSERT', 'players_favorite',
            data: {
              'id_club': widget.user.selectedClub!.id,
              'id_player': widget.player.id,
              if (_notes != null) 'notes': _notes,
              if (_dateDelete != null)
                'date_delete': _dateDelete!.toIso8601String(),
            },
            messageSuccess:
                'Successfully set ${widget.player.getFullName()} in the list of favorite players');

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
          Text('Remove from favorite'),
        ],
      ),
      onPressed: () async {
        await operationInDB(context, 'DELETE', 'players_favorite',
            matchCriteria: {'id': widget.player.favorite!.id},
            messageSuccess:
                'Successfully removed ${widget.player.getFullName()} from the list of favorite players');

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
        await operationInDB(context, 'UPDATE', 'players_favorite',
            data: {
              'id': widget.player.favorite!.id,
              if (_notes != widget.player.favorite?.notes) 'notes': _notes,
              if (_dateDelete != widget.player.favorite?.dateDelete)
                'date_delete':
                    _dateDelete != null ? _dateDelete!.toIso8601String() : null,
            },
            matchCriteria: {'id': widget.player.favorite!.id},
            messageSuccess:
                'Successfully updated ${widget.player.getFullName()} in the list of favorite players');

        Navigator.of(context).pop();
      },
    );
  }
}
