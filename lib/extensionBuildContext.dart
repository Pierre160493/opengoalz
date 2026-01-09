import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

/// Set of extension methods to easily display a snackbar
extension ShowSnackBar on BuildContext {
  void showSnackBar(String message,
      {Icon? icon = null, Color? backgroundColor = null}) {
    print('showSnackBar called with message: $message');
    ScaffoldMessenger.of(this).showSnackBar(
      // ScaffoldMessenger.of(this, rootNavigator: true).showSnackBar(
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
            Text(message, style: TextStyle(fontSize: fontSizeMedium)),
          ],
        ),
        backgroundColor: backgroundColor,
        showCloseIcon: true,
      ),
    );
  }

  /// Displays a red snackbar indicating error
  void showSnackBarSuccess(String message, {Icon? icon = null}) {
    icon ??= Icon(iconSuccessfulOperation, color: Colors.green);
    showSnackBar(message, icon: icon);
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
              content: Text(text, style: TextStyle(fontSize: fontSizeMedium)),
              actions: <Widget>[
                TextButton(
                  child: Row(
                    children: [
                      Icon(
                        iconSuccessfulOperation,
                        size: iconSizeMedium,
                        color: Colors.green,
                      ),
                      formSpacer3,
                      Text('Confirm', style: TextStyle(fontSize: fontSizeMedium)),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true
                  },
                ),
                TextButton(
                  child: persoCancelRow(),
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

extension ConfirmationDialogWith2Options on BuildContext {
  Future<bool> showConfirmationDialogWith2Options(
      String text, String textOpt1, String textOpt2) async {
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
                      Text(textOpt1),
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
                        iconSuccessfulOperation,
                        color: Colors.green,
                      ),
                      SizedBox(width: 3.0),
                      Text(textOpt2),
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
