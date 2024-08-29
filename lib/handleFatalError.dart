import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:flutter/services.dart'; // For SystemNavigator.pop()
import 'dart:io'; // For exit(0)

Future<void> handleFatalError(BuildContext context, String message) async {
  try {
    /// Display an alert dialog for the fatal error
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(iconError, color: Colors.red),
              Text('Fatal Error'),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    // Display a snackbar with the error message
    context.showSnackBarError(message);

    // Sign out the user
    await supabase.auth.signOut();

    // Redirect to the login page
    Navigator.of(context)
        .pushAndRemoveUntil(LoginPage.route(), (route) => false);
  } catch (error) {
    // Handle any errors that occur during the error handling process
    print('An error occurred while handling a fatal error: $error');

    // Close the app
    if (Platform.isAndroid || Platform.isIOS) {
      SystemNavigator.pop();
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      exit(0);
    }
  }
}
