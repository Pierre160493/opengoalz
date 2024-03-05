import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club.dart';
import 'package:opengoalz/global_variable.dart';
import 'package:opengoalz/pages/chat_page.dart';
import 'package:opengoalz/pages/fans_page.dart';
import 'package:opengoalz/pages/finances_page.dart';
import 'package:opengoalz/pages/games_page.dart';
import 'package:opengoalz/pages/home_page.dart';
import 'package:opengoalz/pages/players_page.dart';
import 'package:opengoalz/pages/ranking_page.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Club selectedClub = Provider.of<SessionProvider>(context).selectedClub;

    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home), // Add the home icon
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
          buildDrawerTitle('Club: ${selectedClub.club_name ?? 'No club Name'}'),
          buildDrawerOption(
              context,
              Icons.savings_outlined,
              'Finances:     ${NumberFormat.decimalPattern().format(selectedClub.finances_cash)} €',
              FinancesPage(
                  idClub: selectedClub.id_club)), // Add the finances page
          buildDrawerOption(context, Icons.campaign_outlined, 'Fans',
              FansPage(idClub: selectedClub.id_club)), // Add the fans page
          buildDrawerOption(
            context,
            Icons.stadium_outlined,
            'Stadium',
          ), // Add the Stadium page
          buildDrawerOption(
            context,
            Icons.engineering_outlined,
            'Staff',
          ), // Add the Staff page
          buildDrawerOption(
            context,
            Icons.camera_indoor_outlined,
            'Scouts',
          ), // Add the Scouts page
          buildDrawerOption(
              context, Icons.healing, 'Medics'), // Add the Medics page
          buildDrawerTitle('Main Team'), // Add the Main Team page
          buildDrawerOption(
              context,
              Icons.diversity_3,
              'Players (${selectedClub.player_count})',
              PlayersPage(
                  idClub: selectedClub.id_club)), // Add the Players page
          buildDrawerOption(
            context,
            Icons.currency_exchange,
            'Transfers',
          ), // Add the Transfers page
          buildDrawerOption(context, Icons.event_outlined, 'Games',
              const GamesPage()), // Add the Games page
          buildDrawerOption(context, Icons.emoji_events_outlined, 'Rankings',
              const RankingPage(idLeague: 1)), // Add the Rankings page
          buildDrawerOption(
            context,
            Icons.query_stats,
            'Training',
          ), // Add the Training page
          buildDrawerTitle('Young Team'),

          const SizedBox(
            height: 15,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'This is some information about the app or the navigation.',
              style: TextStyle(
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          buildDrawerOption(context, Icons.wechat_outlined, 'Chat',
              const ChatPage()), // Add the Rankings page
        ],
      ),
    );
  }
}

Widget buildDrawerTitle(String title) {
  return Container(
    color: Colors.blueGrey,
    child: ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24.0,
        ),
      ),
      onTap: () {
        // Handle navigation
      },
    ),
  );
}

Widget buildDrawerOption(BuildContext context, IconData icon, String title,
    [Widget? page]) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: page != null
        ? () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        : null,
  );
}
