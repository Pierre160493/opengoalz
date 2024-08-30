import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client
final supabase = Supabase.instance.client;

/// App Name
// const appName = 'OpenGoalZ';
const appName = 'BenchWarmer Manager';

/// App Bar Text
// const appBarTxt = '$appName: The Open Source Football Manager Game';
const appBarTxt = appName;
// const appBarTxt = '$appName: AppBarTxt';

/// Simple preloader inside a Center widget
const preloader = Center(child: CircularProgressIndicator(color: Colors.green));

/// Simple sized box to space out form elements
const formSpacer3 = SizedBox(width: 3, height: 3);
const formSpacer6 = SizedBox(width: 6, height: 6);
const formSpacer12 = SizedBox(width: 12, height: 12);

/// Some padding for all the forms to use
const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

const maxWidth = 600.0;

/// Icons

const icon_home = Icons.home;
const icon_finance = Icons.savings_outlined;
const icon_fans = Icons.campaign_outlined;
const icon_stadium = Icons.stadium_outlined;
const iconStaff = Icons.engineering_outlined;
const icon_scouts = Icons.camera_indoor_outlined;
const iconInjury = Icons.healing;
const icon_players = Icons.diversity_3;
const iconTransfers = Icons.currency_exchange;
const iconGames = Icons.event;
const iconCalendar = Icons.calendar_month;
const iconNotes = Icons.event_note;
const iconLeaveClub = Icons.door_sliding;
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
const iconError = Icons.error;
const iconSuccessfulOperation = Icons.check_circle;
const iconPostgreSQLError = Icons.report;
const iconAnnouncement = Icons.campaign_outlined;
const iconShirt = Icons.checkroom;
// const iconMultiverseSpeed = Icons.speed;
const iconMultiverseSpeed = Icons.shutter_speed;

/// Color for players or clubs belonging to the currently connected user
const Color colorIsMine = Colors.purple;

/// Text Styles
const TextStyle italicBlueGreyTextStyle = TextStyle(
  fontStyle: FontStyle.italic,
  color: Colors.blueGrey,
);

double iconSizeSmall = 24.0;
double iconSizeMedium = 30.0;
double iconSizeLarge = 36.0;
