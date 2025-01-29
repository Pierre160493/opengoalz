import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/playerFavorite/player_favorite.dart';
import 'package:opengoalz/models/playerFavorite/playersFavoriteTab.dart';
import 'package:opengoalz/models/playerPoaching/player_poaching.dart';
import 'package:opengoalz/models/playerPoaching/playersPoachingTab.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:opengoalz/pages/scouts_page/scoutsTab.dart';
import 'package:provider/provider.dart';
import 'package:opengoalz/provider_user.dart';

enum ScoutsPageTab { scoutingNetwork, followedPlayers, poachedPlayers }

class ScoutsPage extends StatefulWidget {
  final Profile user;
  final ScoutsPageTab initialTab; // Modify this line
  const ScoutsPage(
      {Key? key,
      required this.user,
      this.initialTab = ScoutsPageTab.scoutingNetwork})
      : super(key: key); // Modify this line

  static Route<void> route(Profile user,
      {ScoutsPageTab initialTab = ScoutsPageTab.scoutingNetwork}) {
    // Modify this line
    return MaterialPageRoute(
      builder: (context) =>
          ScoutsPage(user: user, initialTab: initialTab), // Modify this line
    );
  }

  @override
  State<ScoutsPage> createState() => _ScoutsPageState();
}

class _ScoutsPageState extends State<ScoutsPage> {
  int _costForNewPlayer = 7000;
  late Profile _user;
  late Stream<List<Player>> _playerStream;

  @override
  void initState() {
    super.initState();

    _user = widget.user;

    _playerStream = supabase
        .from('players')
        .stream(primaryKey: ['id'])
        .inFilter('id', [
          ..._user.selectedClub!.playersFavorite.map((pf) => pf.idPlayer),
          ..._user.selectedClub!.playersPoached.map((pp) => pp.idPlayer)
        ])
        .order('date_birth', ascending: true)
        .map((maps) => maps.map((map) => Player.fromMap(map)).toList())
        .map((List<Player> players) {
          print('Followed Players: ${players.length}');
          for (PlayerFavorite pf in _user.selectedClub!.playersFavorite) {
            Player? player =
                players.firstWhere((player) => player.id == pf.idPlayer);
            pf.player = player;
          }
          for (PlayerPoaching pp in _user.selectedClub!.playersPoached) {
            Player? player =
                players.firstWhere((player) => player.id == pp.idPlayer);
            pp.player = player;
          }
          return players;
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Player>>(
      stream: _playerStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No players found.'));
        } else {
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
                    widget.initialTab == ScoutsPageTab.scoutingNetwork ? 0 : 1,
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
                getPlayersWidget(context,
                    club.playersFavorite.map((pf) => pf.player!).toList()),
                getPlayersPoachingTab(club.playersPoached),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
