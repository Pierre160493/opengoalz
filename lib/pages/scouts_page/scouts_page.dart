import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/widgets/playerCard_Main.dart';
import 'package:opengoalz/models/playerPoaching/playersPoachingTab.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
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
        final _user = userSessionProvider.user;
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
              return loadingCircularAndText('Loading players...');
            } else if (snapshot.hasError) {
              return ErrorWithBackButton(
                  errorMessage: snapshot.error.toString());
            } else {
              print(
                  'ScoutsPage: _user.selectedClub!.playersFavorite: ${_user.selectedClub!.playersFavorite.length}');
              final players = snapshot.data ?? [];
              // for (Player player in players) {
              //   print('ScoutsPage: player: ${player.id}');
              //   player.favorite = _user.selectedClub!.playersFavorite
              //       .firstWhere((pf) => pf.idPlayer == player.id orElse: () => null);
              //   player.poaching = _user.selectedClub!.playersPoached
              //       .firstWhere((pp) => pp.idPlayer == player.id);
              // }
              print('ScoutsPage2: snapshot.data: ${snapshot.data}');

              return Scaffold(
                appBar: AppBar(
                  title: Row(
                    children: [
                      Text('Scouting Network of '),
                      _user.selectedClub!.getClubNameClickable(context),
                    ],
                  ),
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
                              _getFollowedPlayersTab(_user, players),
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

  Widget _getFollowedPlayersTab(Profile user, List<Player> players) {
    List<Player> playersFavorite =
        players.where((player) => player.favorite != null).toList();
    List<Player> playersPoached =
        players.where((player) => player.poaching != null).toList();
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab == ScoutsPageTab.poachedPlayers ? 1 : 0,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(
                  icon: iconScouts,
                  text: 'Favorites (${playersFavorite.length})'),
              buildTabWithIcon(
                icon: iconFavorite,
                text: 'Poaching (${playersPoached.length})',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                /// Favorites
                playersFavorite.length == 0
                    ? ErrorWithBackButton(
                        errorMessage: 'No favorite players found')
                    : ListView.builder(
                        itemCount: playersFavorite.length,
                        itemBuilder: (context, index) {
                          Player player = playersFavorite[index];
                          return player.favorite == null
                              ? Text('null')
                              : PlayerCard(
                                  player: player,
                                  index: index + 1,
                                  isExpanded: false);
                        },
                      ),

                /// Poached
                getPlayersPoachingTab(playersPoached, user),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
