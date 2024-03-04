import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
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
    // await for for the widget to mount
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    final sessionProvider =
        Provider.of<SessionProvider>(context, listen: false);
    if (session == null) {
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } else {
      sessionProvider.setLoggedIn(true); // Set isLoggedIn to true
      sessionProvider.updateClubStream(
          supabase.auth.currentUser!.id); // Update the club stream

      sessionProvider.clubStream.listen((clubs) {
        print(clubs.length);
        for (Club club in clubs) {
          if (club.is_default) {
            sessionProvider.setnClubInList(clubs.indexOf(club));
          }
        }
      });
      // GlobalVariable.userID = session?.user?.id;
      // sessionProvider.setnClubInList(Null as int?); // Set isLoggedIn to true
      Navigator.of(context)
          .pushAndRemoveUntil(HomePage.route(), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
