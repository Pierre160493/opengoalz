import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/user_page.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/pages/offline_page.dart'; // Import the offline page
import 'package:provider/provider.dart';
import '../constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  bool _showOfflineButton = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _redirect();
    _startTimeout();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero); // Await for the widget to mount

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
        setState(() {
          _isConnected = true;
        });
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
      print('############ End of _redirect()');
    }
  }

  void _startTimeout() {
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showOfflineButton = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: preloader),
          if (_showOfflineButton)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        OfflinePage.route(onReturn: _onReturnFromOffline));
                  },
                  child: Text('Go to Offline Page'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onReturnFromOffline() {
    if (_isConnected) {
      Navigator.of(context)
          .pushAndRemoveUntil(UserPage.route(), (route) => false);
    }
  }
}
