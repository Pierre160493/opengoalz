import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'dart:math';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/postgresql_requests.dart';

class PlayerNotesDialogBox extends StatefulWidget {
  final Player player;
  PlayerNotesDialogBox({required this.player});
  @override
  _PlayerNotesDialogBoxState createState() => _PlayerNotesDialogBoxState();
}

class _PlayerNotesDialogBoxState extends State<PlayerNotesDialogBox> {
  final TextEditingController _smallNotesController = TextEditingController();
  final TextEditingController _largeNotesController = TextEditingController();
  late String _smallNotes;
  String? _smallNotesErrorMessage;
  late bool _isSmallNotesValid;

  @override
  void initState() {
    super.initState();

    initControlers();

    _smallNotesController.addListener(() {
      setState(() {
        _smallNotesErrorMessage = _validateNotes();
      });
    });
    _largeNotesController.addListener(() {
      setState(() {});
    });
    _smallNotesErrorMessage = _validateNotes();
  }

  void initControlers() {
    _smallNotesController.text = widget.player.notesSmall;
    _largeNotesController.text = widget.player.notes;
  }

  @override
  void dispose() {
    _smallNotesController.removeListener(_validateNotes);
    _smallNotesController.dispose();
    _largeNotesController.removeListener(() {});
    _largeNotesController.dispose();
    super.dispose();
  }

  String? _validateNotes() {
    _isSmallNotesValid = false;

    // if (_smallNotesController.text.isEmpty) {
    //   _smallNotes = '';
    //   _isSmallNotesValid = true;
    //   return null; // Allow empty input as valid
    // }

    _smallNotes = _smallNotesController.text;

    // if (_smallNotes == widget.player.notesSmall) {
    //   return 'Small Notes are alrea is already ${widget.player.shirtNumber}';
    // }

    if (_smallNotes.length > 6) {
      _smallNotes = '';
      return 'The Small Notes cannot exceed 6 characters';
    }

    _isSmallNotesValid = true;
    return null;
  }

  bool _isNotesModified() {
    return _smallNotesController.text != widget.player.notesSmall ||
        _largeNotesController.text != widget.player.notes;
  }

  void _onEnterPressed() async {
    if (_isSmallNotesValid) {
      await operationInDB(context, 'UPDATE', 'players',
          data: {
            'notes_small': _smallNotes,
            'notes': _largeNotesController.text
          },
          matchCriteria: {'id': widget.player.id},
          messageSuccess:
              'Successfully changed the notes ${widget.player.getPlayerNameString()}');

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AlertDialog(
          title: Row(
            children: [
              Text('Notes on '),
              widget.player.getPlayerNameToolTip(context),
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
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                          color: _isSmallNotesValid ? Colors.green : Colors.red,
                          width: 2.0),
                    ),
                    leading: Icon(
                      iconNotesSmall,
                      color: _isSmallNotesValid ? Colors.green : Colors.red,
                    ),
                    title: TextFormField(
                      controller: _smallNotesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Small Notes (6 characters max)',
                        border: OutlineInputBorder(),
                        errorText: _smallNotesErrorMessage,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _isSmallNotesValid
                                ? Colors.green
                                : Colors
                                    .red, // Change border color based on validation
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _isSmallNotesValid
                                ? Colors.green
                                : Colors
                                    .red, // Change border color based on validation
                          ),
                        ),
                      ),
                      onFieldSubmitted: (value) => _onEnterPressed(),
                    ),
                  ),
                  formSpacer6,
                  // PostItNote(player: widget.player),
                  Container(
                    padding: EdgeInsets.all(6.0),
                    // margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.yellow[200],
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _largeNotesController,
                          maxLines: null,
                          decoration: InputDecoration(
                            // hintText: 'No notes yet on this player',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
                  child: persoCancelRow(),
                ),
                if (_isNotesModified())
                  TextButton(
                    onPressed: () {
                      initControlers();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        formSpacer3,
                        Text('Reset'),
                      ],
                    ),
                  ),
                if (_isNotesModified())
                  if (_isSmallNotesValid)
                    TextButton(
                      onPressed: _onEnterPressed,
                      child: Row(
                        children: [
                          Icon(iconSuccessfulOperation, color: Colors.green),
                          formSpacer3,
                          Text('Update notes on '),
                          widget.player.getPlayerNameToolTip(context)
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
