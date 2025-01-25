import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/playerFavorite/player_favorite.dart';
import 'package:opengoalz/models/playerFavorite/playersFavoriteTab.dart';
import 'package:opengoalz/models/playerPoaching/playersPoachingTab.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/pages/scouts_page/scoutsTab.dart';
import 'package:opengoalz/models/playerPoaching/player_poaching.dart';

class ScoutsPage extends StatefulWidget {
  final Club club;
  const ScoutsPage({Key? key, required this.club}) : super(key: key);

  static Route<void> route(Club club) {
    return MaterialPageRoute(
      builder: (context) => ScoutsPage(club: club),
    );
  }

  @override
  State<ScoutsPage> createState() => _ScoutsPageState();
}

class _ScoutsPageState extends State<ScoutsPage> {
  int _costForNewPlayer = 7000;
  late Stream<List<Player>> _playersStream;

  @override
  void initState() {
    final playersFavoriteStream = supabase
        .from('players_favorite')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.club.id)
        .map((maps) => maps.map((map) => PlayerFavorite.fromMap(map)).toList());

    final playersPoachingStream = supabase
        .from('players_poaching')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.club.id)
        .map((maps) => maps.map((map) => PlayerPoaching.fromMap(map)).toList());

    _playersStream = Rx.combineLatest2(
      playersFavoriteStream,
      playersPoachingStream,
      (List<PlayerFavorite> favorites, List<PlayerPoaching> poachings) {
        final playerIds = [
          ...favorites.map((e) => e.idPlayer),
          ...poachings.map((e) => e.idPlayer)
        ].toSet().toList();

        return supabase
            .from('players')
            .stream(primaryKey: ['id'])
            .inFilter('id', playerIds)
            .map((maps) {
              final players = maps.map((map) => Player.fromMap(map)).toList();
              players.forEach((player) {
                print('player.id: ${player.id}');
                for (var favorite in favorites) {
                  if (favorite.idPlayer == player.id) {
                    player.favorite = favorite;
                    break;
                  }
                }
                for (var poaching in poachings) {
                  if (poaching.idPlayer == player.id) {
                    player.poaching = poaching;
                    break;
                  }
                }
              });
              return players;
            });
      },
    ).switchMap((stream) => stream);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          child: StreamBuilder<List<Player>>(
            stream: _playersStream,
            builder: (context, snapshot) {
              return Column(
                children: [
                  TabBar(
                    tabs: [
                      buildTabWithIcon(
                          icon: iconScouts, text: 'Scouting network'),
                      buildTabWithIcon(
                        icon: iconFavorite,
                        text:
                            snapshot.connectionState == ConnectionState.waiting
                                ? 'Loading...'
                                : 'Followed (${snapshot.data!.length})',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ScoutsMainTab(widget.club),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          Center(child: CircularProgressIndicator())
                        else if (snapshot.hasError)
                          Center(child: Text('Error loading players'))
                        else if (!snapshot.hasData || snapshot.data!.isEmpty)
                          Center(child: Text('No players found'))
                        else
                          _getFollowedPlayersTab(snapshot.data!),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getFollowedPlayersTab(List<Player> players) {
    print('players: ${players.length}');
    List<Player> playersFavorite =
        players.where((player) => player.favorite != null).toList();
    List<Player> playersPoaching =
        players.where((player) => player.poaching != null).toList();
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(
                  icon: iconScouts,
                  text: 'Favorites (${playersFavorite.length})'),
              buildTabWithIcon(
                icon: iconFavorite,
                text: 'Poaching (${playersPoaching.length})',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                getPlayersWidget(context, playersFavorite),
                getPlayersPoachingTab(playersPoaching),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
