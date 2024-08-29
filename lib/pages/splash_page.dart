import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/user_page.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:provider/provider.dart';
import '../constants.dart';

/// Page to redirect users to the appropriate page depending on the initial auth state
class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    print('Redirecting to the appropriate page');
    await Future.delayed(Duration
        .zero); // await for for the widget to mount, otherwise app freezes

    if (supabase.auth.currentSession == null) {
      print('############ supabase.auth.currentSession is null');
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } else {
      print('############ supabase.auth.currentSession is not null');
      // Fetch the user from the database
      try {
        await Provider.of<SessionProvider>(context, listen: false)
            .providerFetchUser(context, userId: supabase.auth.currentUser!.id);

        print('############ User found, try to launch UserPage');
        Navigator.of(context)
            .pushAndRemoveUntil(UserPage.route(), (route) => false);
      } catch (error) {
        print('############ User not found, redirecting to LoginPage');
        print('# ${error.toString()}');
        // Handle the case where the user is not found

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('User not found. Redirecting to login page.'),
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

        context.showSnackBarError('User not found. Redirecting to login page.');

        await supabase.auth.signOut(); // Sign out the user
        Navigator.of(context)
            .pushAndRemoveUntil(LoginPage.route(), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
