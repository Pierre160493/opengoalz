import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerCard_Main.dart';
import 'package:opengoalz/models/playerFavorite/player_favorite.dart';
import 'package:opengoalz/models/playerPoaching/player_poaching.dart';
import 'package:opengoalz/models/playerPoaching/playersPoachingTab.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:opengoalz/pages/scouts_page/scoutsTab.dart';
import 'package:provider/provider.dart';

enum ScoutsPageTab { scoutingNetwork, followedPlayers, poachedPlayers }

class ScoutsPage extends StatefulWidget {
  final ScoutsPageTab initialTab; // Modify this line
  const ScoutsPage({Key? key, this.initialTab = ScoutsPageTab.scoutingNetwork})
      : super(key: key); // Modify this line

  static Route<void> route(
      {ScoutsPageTab initialTab = ScoutsPageTab.scoutingNetwork}) {
    // Modify this line
    return MaterialPageRoute(
      builder: (context) =>
          ScoutsPage(initialTab: initialTab), // Modify this line
    );
  }

  @override
  State<ScoutsPage> createState() => _ScoutsPageState();
}

class _ScoutsPageState extends State<ScoutsPage> {
  int _costForNewPlayer = 7000;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionProvider>(
      builder: (context, userSessionProvider, child) {
        final _user = userSessionProvider.user!;
        final followedPlayerIds = [
          ..._user.selectedClub!.playersFavorite.map((pf) => pf.idPlayer),
          ..._user.selectedClub!.playersPoached.map((pp) => pp.idPlayer)
        ];

        return StreamBuilder<List<Player>>(
          stream: supabase
              .from('players')
              .stream(primaryKey: ['id'])
              .inFilter('id', followedPlayerIds)
              .order('date_birth', ascending: true)
              .map((maps) =>
                  maps.map((map) => Player.fromMap(map, _user)).toList()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final players = snapshot.data ?? [];
              for (PlayerFavorite pf in _user.selectedClub!.playersFavorite) {
                pf.player =
                    players.firstWhere((player) => player.id == pf.idPlayer);
              }
              for (PlayerPoaching pp in _user.selectedClub!.playersPoached) {
                pp.player =
                    players.firstWhere((player) => player.id == pp.idPlayer);
              }

              return Scaffold(
                appBar: AppBar(
                  title: Text('Scouting Network'),
                  actions: [
                    Tooltip(
                      message: 'Help',
                      child: IconButton(
                        icon: Icon(Icons.help_outline, color: Colors.green),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Scouting System Help'),
                                content: Text(
                                  'The scouting system allows you to manage and track the expenses and skills of your scouting network.\n\n'
                                  'Every week, you can invest a sum of money into the scouting network to build up its strength.\n\n'
                                  'The expenses dedicated to scouting are theoretical and represent the amount you plan to spend each week, if your finances permit it !\n\n'
                                  'As you continue to invest, the scouting network strength will increase.\n\n'
                                  'Once the scouting strength reaches ${_costForNewPlayer}, you can call the scouts to find a new player.\n\n'
                                  'You can also view the historical data of scouting expenses and the strength of your scouting network over time.',
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  leading: goBackIconButton(context),
                ),
                body: MaxWidthContainer(
                  child: DefaultTabController(
                    length: 2,
                    initialIndex:
                        widget.initialTab == ScoutsPageTab.scoutingNetwork
                            ? 0
                            : 1,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            buildTabWithIcon(
                                icon: iconScouts, text: 'Scouting network'),
                            buildTabWithIcon(
                              icon: iconFavorite,
                              text:
                                  'Followed (${_user.selectedClub!.playersFavorite.length + _user.selectedClub!.playersPoached.length})',
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              ScoutsMainTab(_user.selectedClub!),
                              _getFollowedPlayersTab(_user.selectedClub!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _getFollowedPlayersTab(Club club) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab == ScoutsPageTab.poachedPlayers ? 1 : 0,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(
                  icon: iconScouts,
                  text: 'Favorites (${club.playersFavorite.length})'),
              buildTabWithIcon(
                icon: iconFavorite,
                text: 'Poaching (${club.playersPoached.length})',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView.builder(
                  itemCount: club.playersFavorite.length,
                  itemBuilder: (context, index) {
                    PlayerFavorite playerFavorite = club.playersFavorite[index];
                    return playerFavorite.player == null
                        ? Text('null')
                        : PlayerCard(
                            player: playerFavorite.player!,
                            index: index + 1,
                            isExpanded: false);
                  },
                ),
                getPlayersPoachingTab(club.playersPoached),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
