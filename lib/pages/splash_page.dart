import 'package:flutter/material.dart';
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
    await Future.delayed(Duration
        .zero); // await for for the widget to mount, otherwise app freezes

    if (supabase.auth.currentSession == null) {
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } else {
      ///
      await Provider.of<SessionProvider>(context, listen: false)
          .providerFetchUser(userId: supabase.auth.currentUser!.id);

      Navigator.of(context)
          .pushAndRemoveUntil(UserPage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
