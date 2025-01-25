import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/calendar_page.dart';
import 'package:opengoalz/pages/country_page.dart';
import 'package:opengoalz/pages/mails_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:opengoalz/pages/scouts_page/scouts_page.dart';
import 'package:opengoalz/pages/staff_page.dart';
import 'package:opengoalz/pages/teamCompsPage.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/chat_page.dart';
import 'package:opengoalz/pages/finances_page.dart';
import 'package:opengoalz/pages/games_page.dart';
import 'package:opengoalz/pages/user_page.dart';
import 'package:opengoalz/pages/transfer_page.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:opengoalz/widgets/customListTile.dart';
import 'package:opengoalz/widgets/mailsWidget.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _expandedTile;

  @override
  void initState() {
    super.initState();
    _expandedTile = 'Desktop'; // Initialize the expanded tile
  }

  @override
  Widget build(BuildContext context) {
    // Get the selected club
    Profile user = Provider.of<SessionProvider>(context).user!;
    Club? selectedClub = user.selectedClub;

    if (selectedClub == null) {
      return const Drawer(
        child: Center(
          child: Text('No club selected'),
        ),
      );
    }

    return Drawer(
      child: ListView(
        children: [
          /// User Tile
          CustomListTile(
            title: user.getUserName(context),
            subtitle: !user.isConnectedUser
                ? Text('Currently visiting this profile')
                : null,
            page: const UserPage(),
          ),

          /// Add the club name and ranking
          CustomListTile(
            leadingIcon: iconClub,
            leadingIconSize: iconSizeLarge,
            title: selectedClub.getClubNameClickable(context),
            subtitle: selectedClub.getClubRankingRow(context),
            shape: shapePersoRoundedBorder(Colors.green, 3),
          ),

          /// Expansion Tile for various sections
          ExpansionTile(
            key: Key('Desktop_${_expandedTile == 'Desktop'}'),
            leading:
                Icon(Icons.event_seat, size: iconSizeLarge, color: Colors.blue),
            title: Text('Desktop'),
            subtitle: Text('Main club actions', style: styleItalicBlueGrey),
            shape: shapePersoRoundedBorder(Colors.blue),
            initiallyExpanded: _expandedTile == 'Desktop',
            onExpansionChanged: (bool expanded) {
              setState(() {
                _expandedTile = expanded ? 'Desktop' : null;
                print('expanded: $expanded ($_expandedTile)');
              });
            },
            children: [
              /// Calendar Tile
              CustomListTile(
                leadingIcon: iconCalendar,
                leadingIconSize: iconSizeMedium,
                title: Text('Calendar'),
                // shape: shapePersoRoundedBorder(),
                page: CalendarPage(idClub: selectedClub.id),
              ),

              /// Mails Tile
              CustomListTile(
                leadingWidget: mailToolTip(context, user),
                leadingIconSize: iconSizeMedium,
                title: Text('Mails'),
                // shape: shapePersoRoundedBorder(),
                page: MailsPage(idClub: selectedClub.id),
              ),

              /// Finances Tile
              CustomListTile(
                leadingIcon: iconCash,
                leadingIconSize: iconSizeMedium,
                title: Text('Finances'),
                subtitle: Row(
                  children: [
                    Icon(iconMoney,
                        color: selectedClub.clubData.cash >= 0
                            ? Colors.green
                            : Colors.red),
                    formSpacer6,
                    Text(
                      persoFormatCurrency(selectedClub.clubData.cash),
                      style: TextStyle(
                        color: selectedClub.clubData.cash >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // shape: shapePersoRoundedBorder(),
                page: FinancesPage(club: selectedClub),
              ),

              /// Staff Tile
              CustomListTile(
                leadingIcon: iconStaff,
                leadingIconSize: iconSizeMedium,
                title: Text(
                  'Staff',
                ),
                // shape: shapePersoRoundedBorder(),
                page: StaffPage(idClub: selectedClub.id),
              ),

              /// Scouts Tile
              CustomListTile(
                leadingIcon: iconScouts,
                leadingIconSize: iconSizeMedium,
                title: Text('Scouts'),
                // shape: shapePersoRoundedBorder(),
                page: ScoutsPage(club: selectedClub),
              ),

              /// Transfers Tile
              CustomListTile(
                leadingIcon: iconTransfers,
                leadingIconSize: iconSizeMedium,
                title: Text('Transfers'),
                page: TransferPage(idClub: selectedClub.id),
                // shape: shapePersoRoundedBorder(),
              ),
            ],
          ),

          /// Expansion Tile for Main Team
          ExpansionTile(
            key: Key('MainTeam_${_expandedTile == 'Main Team'}'),
            leading: Icon(Icons.group, size: iconSizeLarge, color: Colors.blue),
            title: Text('Main Team'),
            subtitle: Text('Team management', style: styleItalicBlueGrey),
            shape: shapePersoRoundedBorder(Colors.blue),
            initiallyExpanded: _expandedTile == 'Main Team',
            onExpansionChanged: (bool expanded) {
              setState(() {
                _expandedTile = expanded ? 'Main Team' : null;
              });
            },
            children: [
              /// Players Tile
              CustomListTile(
                leadingIcon: iconPlayers,
                leadingIconSize: iconSizeMedium,
                title: Text('Players'),
                // shape: shapePersoRoundedBorder(),
                page: PlayersPage(
                  playerSearchCriterias:
                      PlayerSearchCriterias(idClub: [selectedClub.id]),
                ),
              ),

              /// Games Tile
              CustomListTile(
                leadingIcon: iconGames,
                leadingIconSize: iconSizeMedium,
                title: Text('Games'),
                // shape: shapePersoRoundedBorder(),
                page: GamesPage(idClub: selectedClub.id),
              ),

              /// TeamComps Tile
              CustomListTile(
                leadingIcon: iconTeamComp,
                leadingIconSize: iconSizeMedium,
                title: Text('TeamComps'),
                // shape: shapePersoRoundedBorder(),
                page: TeamCompsPage(
                    idClub: selectedClub.id,
                    seasonNumber: selectedClub.seasonNumber),
              ),

              /// League Tile
              CustomListTile(
                leadingIcon: iconLeague,
                leadingIconSize: iconSizeMedium,
                title: Text('League'),
                // shape: shapePersoRoundedBorder(),
                page: LeaguePage(
                  idLeague: selectedClub.idLeague,
                  idSelectedClub: selectedClub.id,
                ),
                subtitle: selectedClub.getClubRankingRow(context),
              ),
            ],
          ),

          /// Other Title
          /// Expansion Tile for Main Team
          ExpansionTile(
            key: Key('Other_${_expandedTile == 'Other'}'),
            leading: Icon(Icons.playlist_add_outlined,
                size: iconSizeLarge, color: Colors.blue),
            title: Text('Other'),
            subtitle: Text('Other', style: styleItalicBlueGrey),
            shape: shapePersoRoundedBorder(Colors.blue),
            initiallyExpanded: _expandedTile == 'Other',
            onExpansionChanged: (bool expanded) {
              setState(() {
                _expandedTile = expanded ? 'Other' : null;
              });
            },
            children: [
              /// Chat Tile
              CustomListTile(
                leadingIcon: iconChat,
                title: Text('Chat'),
                // shape: shapePersoRoundedBorder(),
                page: const ChatPage(),
              ),

              /// Multiverse Tile
              CustomListTile(
                leadingIcon: iconMultiverseSpeed,
                title: Text('Multiverses'),
                // shape: shapePersoRoundedBorder(),
                page: MultiversePage(
                    idMultiverse: user.selectedClub!.idMultiverse),
              ),

              /// Countries Tile
              CustomListTile(
                leadingIcon: iconCountries,
                title: Text('Countries'),
                // shape: shapePersoRoundedBorder(),
                page: CountryPage(
                    idCountry: user.selectedClub!.idCountry,
                    idMultiverse: user.selectedClub!.idMultiverse),
              ),
            ],
          ),

          /// Chat Tile
        ],
      ),
    );
  }
}
