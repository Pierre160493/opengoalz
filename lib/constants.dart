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

const maxWidth = 600.0;

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
const iconGames = Icons.event;
const iconCalendar = Icons.calendar_month;
const iconNotes = Icons.event_note;
// const icon_league = Icons.emoji_events_outlined;
const icon_league = Icons.format_list_numbered;
const iconTraining = Icons.query_stats;
const icon_chat = Icons.wechat_outlined;
// const icon_club = Icons.real_estate_agent_outlined;
const icon_club = Icons.home_work_rounded;
const iconDetails = Icons.description;
const iconHistory = Icons.history_edu;
const iconMoney = Icons.monetization_on_outlined;
const iconUser = Icons.account_circle;
const iconBot = Icons.smart_toy_outlined;
const iconAge = Icons.cake_outlined;
const iconTeamComp = Icons.grid_on;
const iconMails = Icons.email;
const iconStamina = Icons.ev_station;
// const iconBug = Icons.bug_report;
const iconBug = Icons.error;
const iconSuccessfulOperation = Icons.check_circle;

/// Color for players or clubs belonging to the currently connected user
const Color colorIsMine = Colors.purple;

double iconSizeSmall = 24.0;
double iconSizeMedium = 30.0;
double iconSizeLarge = 36.0;

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
