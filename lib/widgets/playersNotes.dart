import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/postgresql_requests.dart';

class PostItNote extends StatefulWidget {
  final Player player;

  const PostItNote({Key? key, required this.player}) : super(key: key);

  @override
  _PostItNoteState createState() => _PostItNoteState();
}

class _PostItNoteState extends State<PostItNote> {
  late TextEditingController _noteController;
  late ValueNotifier<bool> _isModified;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.player.notes);
    _isModified = ValueNotifier<bool>(false);

    _noteController.addListener(() {
      _isModified.value = _noteController.text != widget.player.notes;
    });
  }

  Future<void> _updateNote() async {
    bool isOK = await operationInDB(
      context,
      'UPDATE',
      'players',
      data: {'notes': _noteController.text},
      matchCriteria: {'id': widget.player.id},
      messageSuccess: 'Successfully updated the player\'s notes',
    );

    if (isOK) {
      _isModified.value = false; // Reset the modified state
    } else {
      context.showSnackBarError('Failed to update the player\'s notes');
    }
  }

  Future<void> _removeNote() async {
    bool? confirm = await context.showConfirmationDialog(
        'Are you sure you want to remove the player\'s notes?');

    if (confirm != true) {
      return;
    }

    bool isOK = await operationInDB(
      context,
      'UPDATE',
      'players',
      data: {'notes': null},
      matchCriteria: {'id': widget.player.id},
    );

    if (isOK) {
      _noteController.text = ''; // Clear the text in the TextField
      context.showSnackBarSuccess('Successfully removed the player\'s notes');
      _isModified.value = false; // Reset the modified state
    } else {
      context.showSnackBarError('Failed to remove the player\'s notes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(36.0),
              margin: EdgeInsets.all(12.0),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Player\'s Notes',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height:
                            8.0), // Add some space between "Notes" and the actual note
                    TextField(
                      controller: _noteController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'No notes yet on this player',
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 8.0),
          ValueListenableBuilder<bool>(
            valueListenable: _isModified,
            builder: (context, isModified, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isModified)
                    IconButton(
                      tooltip: 'Save Notes',
                      icon: Icon(
                        Icons.save,
                        color: Colors.green,
                      ),
                      onPressed: _updateNote,
                    ),
                  IconButton(
                    tooltip: 'Remove Notes',
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    onPressed: _removeNote,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _isModified.dispose();
    super.dispose();
  }
}
