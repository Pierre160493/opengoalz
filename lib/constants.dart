import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client
final supabase = Supabase.instance.client;

/// App Name
const appName = 'OpenGoalZ';

/// App Bar Text
// const appBarTxt = '$appName: The Open Source Football Manager Game';
const appBarTxt = appName;
// const appBarTxt = '$appName: AppBarTxt';

/// Simple preloader inside a Center widget
const preloader = Center(child: CircularProgressIndicator(color: Colors.green));

/// Simple sized box to space out form elements
const formSpacer = SizedBox(width: 16, height: 16);

/// Some padding for all the forms to use
const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

/// Error message to display the user when unexpected error occurs.
const unexpectedErrorMessage = 'Unexpected error occurred.';

/// Icons

const icon_home = Icons.home;
const icon_finance = Icons.savings_outlined;
const icon_fans = Icons.campaign_outlined;
const icon_stadium = Icons.stadium_outlined;
const icon_staff = Icons.engineering_outlined;
const icon_scouts = Icons.camera_indoor_outlined;
const icon_medics = Icons.healing;
const icon_players = Icons.diversity_3;
const icon_transfers = Icons.currency_exchange;
const icon_games = Icons.event_outlined;
const icon_league = Icons.emoji_events_outlined;
const icon_training = Icons.query_stats;
const icon_chat = Icons.wechat_outlined;
// const icon_club = Icons.real_estate_agent_outlined;
const icon_club = Icons.home_work_rounded;

/// Basic theme to change the look and feel of the app
ThemeData getAppTheme(BuildContext context) {
  final isDesktop = Theme.of(context).platform == TargetPlatform.windows ||
      Theme.of(context).platform == TargetPlatform.linux ||
      Theme.of(context).platform == TargetPlatform.macOS;

  // final textScaleFactor = isDesktop ? 1.5 : 1.0; // Adjust based on platform
  final textScaleFactor = isDesktop ? 1.0 : 1.0; // Adjust based on platform

  return ThemeData.dark().copyWith(
    primaryColorDark: Colors.green[800],
    appBarTheme: AppBarTheme(
      elevation: 1,
      backgroundColor: Colors.green,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18 * textScaleFactor,
      ),
    ),
    primaryColor: Colors.green,
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.green,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: TextStyle(
        color: Colors.green,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 2,
        ),
      ),
      focusColor: Colors.green,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.green,
          width: 2,
        ),
      ),
    ),
    textTheme: ThemeData.dark().textTheme.copyWith(
        // titleLarge: TextStyle(
        //     fontSize:
        //         14.0 * textScaleFactor), // Change the default font size here
        // titleSmall: TextStyle(fontSize: 12.0 * textScaleFactor),
        // bodyLarge: TextStyle(fontSize: 11.0 * textScaleFactor),
        // bodySmall: TextStyle(fontSize: 8.0 * textScaleFactor),
        ),
  );
}

/// Set of extension methods to easily display a snackbar
extension ShowSnackBar on BuildContext {
  /// Displays a basic snackbar
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  /// Displays a red snackbar indicating error
  void showErrorSnackBar({required String message}) {
    showSnackBar(message: message, backgroundColor: Colors.red);
  }
}
