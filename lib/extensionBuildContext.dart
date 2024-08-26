import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

/// Set of extension methods to easily display a snackbar
extension ShowSnackBar on BuildContext {
  void showSnackBar(String message,
      {Icon? icon = null, Color? backgroundColor = null}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null)
              Row(
                children: [
                  icon,
                  formSpacer3,
                ],
              ),
            Text(message),
          ],
        ),
        backgroundColor: backgroundColor,
        showCloseIcon: true,
      ),
    );
  }

  /// Displays a red snackbar indicating error
  void showSnackBarError(String message, {Icon? icon = null}) {
    // icon ??= Icon(iconError, color: Colors.red);
    icon ??= Icon(iconError);
    showSnackBar(message, icon: icon, backgroundColor: Colors.red);
  }

  void showSnackBarPostgreSQLError(String message, {Icon? icon}) {
    // Set default icon to error icon
    // icon ??= Icon(iconPostgreSQLError, color: Colors.red);
    icon ??= Icon(iconPostgreSQLError);
    showSnackBarError(message, icon: icon);
  }
}

extension ConfirmationDialog on BuildContext {
  Future<bool> showConfirmationDialog(String text) async {
    return await showDialog(
          context: this,
          builder: (BuildContext context) {
            return AlertDialog(
              // title: Text('Confirmation'),
              content: Text(text),
              actions: <Widget>[
                TextButton(
                  child: Row(
                    children: [
                      Icon(
                        iconSuccessfulOperation,
                        color: Colors.green,
                      ),
                      SizedBox(width: 3.0),
                      Text('Confirm'),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true
                  },
                ),
                TextButton(
                  child: Row(
                    children: [
                      Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      SizedBox(width: 3.0),
                      Text('Cancel'),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false
                  },
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
