import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';

import 'dart:math';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

class PlayerShirtNumberDialogBox extends StatefulWidget {
  final Player player;
  PlayerShirtNumberDialogBox({required this.player});
  @override
  _PlayerShirtNumberDialogBoxState createState() =>
      _PlayerShirtNumberDialogBoxState();
}

class _PlayerShirtNumberDialogBoxState
    extends State<PlayerShirtNumberDialogBox> {
  final TextEditingController _shirtNumberController = TextEditingController();
  int? _shirtNumber;
  String? _shirtNumberErrorMessage;
  late bool _isShirtNumberValid;

  @override
  void initState() {
    super.initState();

    _shirtNumberController.text = widget.player.shirtNumber == null
        ? ''
        : widget.player.shirtNumber.toString();

    _shirtNumberController.addListener(() {
      setState(() {
        _shirtNumberErrorMessage = _validateShirtNumber();
      });
    });
    _shirtNumberErrorMessage = _validateShirtNumber();
  }

  @override
  void dispose() {
    _shirtNumberController.removeListener(_validateShirtNumber);
    _shirtNumberController.dispose();
    super.dispose();
  }

  String? _validateShirtNumber() {
    _isShirtNumberValid = false;

    if (_shirtNumberController.text.isEmpty ||
        _shirtNumberController.text.toUpperCase() == 'NULL') {
      _shirtNumber = null;
      _isShirtNumberValid = true;
      return null; // Allow empty input as valid
    }

    _shirtNumber = int.tryParse(_shirtNumberController.text);
    if (_shirtNumber == null) {
      return 'Invalid shirt number';
    }

    if (_shirtNumber == widget.player.shirtNumber) {
      _shirtNumber = null;
      return 'Shirt Number is already ${widget.player.shirtNumber}';
    }

    if (_shirtNumber! < 0) {
      _shirtNumber = null;
      return 'Shirt Number cannot be negative';
    }

    if (_shirtNumber! > 99) {
      _shirtNumber = null;
      return 'Shirt Number cannot be greater than 99';
    }

    _isShirtNumberValid = true;
    return null;
  }

  void _onEnterPressed() async {
    if (_isShirtNumberValid) {
      bool isOK = await operationInDB(
          context, 'FUNCTION', 'player_change_shirt_number',
          data: {
            'inp_id_player': widget.player.id,
            'inp_id_club': Provider.of<SessionProvider>(context, listen: false)
                .user!
                .selectedClub!
                .id,
            'inp_shirt_number': _shirtNumberController.text.isEmpty
                ? null
                : int.parse(_shirtNumberController.text)
          });

      if (isOK) {
        context.showSnackBar(
            'Successfully changed the shirt number of ${widget.player.getPlayerNameString()}',
            icon: Icon(iconSuccessfulOperation, color: Colors.green));
      }

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
              Text('Shirt Number for '),
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
                          color:
                              _isShirtNumberValid ? Colors.green : Colors.red,
                          width: 2.0),
                    ),
                    leading: Icon(
                      iconShirt,
                      color: _isShirtNumberValid ? Colors.green : Colors.red,
                    ),
                    title: TextFormField(
                      controller: _shirtNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'New shirt number',
                        border: OutlineInputBorder(),
                        errorText: _shirtNumberErrorMessage,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _isShirtNumberValid
                                ? Colors.green
                                : Colors
                                    .red, // Change border color based on validation
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _isShirtNumberValid
                                ? Colors.green
                                : Colors
                                    .red, // Change border color based on validation
                          ),
                        ),
                      ),
                      onFieldSubmitted: (value) => _onEnterPressed(),
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
                if (_isShirtNumberValid)
                  TextButton(
                    onPressed: _onEnterPressed,
                    child: Row(
                      children: [
                        Icon(iconSuccessfulOperation, color: Colors.green),
                        formSpacer3,
                        Text(
                            'Update shirt number to ${_shirtNumberController.text.isEmpty ? 'NULL' : _shirtNumber}'),
                        // widget.player.getPlayerNameToolTip(context)
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
