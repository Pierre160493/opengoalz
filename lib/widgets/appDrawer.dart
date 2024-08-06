import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/club/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/teamCompsPage.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/chat_page.dart';
import 'package:opengoalz/pages/fans_page.dart';
import 'package:opengoalz/pages/finances_page.dart';
import 'package:opengoalz/pages/games_page.dart';
import 'package:opengoalz/pages/user_page.dart';
import 'package:opengoalz/pages/transfer_page.dart';
import 'package:opengoalz/classes/player/players_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Club selectedClub =
        Provider.of<SessionProvider>(context).user!.selectedClub;

    return Drawer(
      child: ListView(
        children: [
          ListTile(
            // leading: const Icon(icon_home), // Add the home icon
            // title: const Text('Home'),
            title: Provider.of<SessionProvider>(context).user!.getUserName(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserPage(),
                ),
              );
            },
            subtitle:
                !Provider.of<SessionProvider>(context).user!.isConnectedUser
                    ? Text('Currently visiting this profile')
                    : null,
            trailing:
                !Provider.of<SessionProvider>(context).user!.isConnectedUser
                    ? Provider.of<SessionProvider>(context)
                        .user!
                        .returnToConnectedUserIconButton(context)
                    : null,
          ),
          buildDrawerTitle('Club: ${selectedClub.name}'),
          buildDrawerOption(
              context,
              icon_finance,
              'Finances:     ${NumberFormat.decimalPattern().format(selectedClub.lisCash.last)} €',
              FinancesPage(idClub: selectedClub.id)), // Add the finances page
          buildDrawerOption(
              context,
              icon_fans,
              'Fans (${selectedClub.numberFans})',
              FansPage(idClub: selectedClub.id)), // Add the fans page
          // buildDrawerOption(
          //   context,
          //   icon_stadium,
          //   'Stadium',
          // ), // Add the Stadium page
          // buildDrawerOption(
          //   context,
          //   icon_staff,
          //   'Staff',
          // ), // Add the Staff page
          // buildDrawerOption(
          //   context,
          //   icon_scouts,
          //   'Scouts',
          // ), // Add the Scouts page
          // buildDrawerOption(
          //     context, icon_medics, 'Medics'), // Add the Medics page
          buildDrawerTitle('Main Team'), // Add the Main Team page
          buildDrawerOption(
              context,
              icon_players,
              // 'Players (${selectedClub.player_count})',
              'Players',
              PlayersPage(inputCriteria: {
                'Clubs': [selectedClub.id]
              })), // Add the Players page
          buildDrawerOption(context, icon_transfers, 'Transfers',
              TransferPage(idClub: selectedClub.id)), // Add the Transfers page
          buildDrawerOption(context, iconGames, 'Games',
              GamesPage(idClub: selectedClub.id)), // Add the Games page
          buildDrawerOption(
              context,
              iconTeamComp,
              'TeamComps',
              TeamCompsPage(
                  idClub: selectedClub.id,
                  seasonNumber:
                      selectedClub.seasonNumber)), // Add the Rankings page
          buildDrawerOption(
              context,
              icon_league,
              'League',
              LeaguePage(
                  idLeague: selectedClub.idLeague)), // Add the Rankings page
          buildDrawerOption(
            context,
            iconTraining,
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
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          buildDrawerOption(context, icon_chat, 'Chat',
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
        style: const TextStyle(fontWeight: FontWeight.bold),
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
