import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/classes/gameUser.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/home_page.dart';
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
    print('SplashPage: initStated');
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration
        .zero); // await for for the widget to mount, otherwise app freezes

    print('SplashPage: _redirect function');
    if (supabase.auth.currentSession == null) {
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } else {
      ///
      await Provider.of<SessionProvider>(context, listen: false)
          .providerFetchUser(supabase.auth.currentUser!.id);

      Navigator.of(context)
          .pushAndRemoveUntil(HomePage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
