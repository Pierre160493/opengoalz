import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/events/event.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/game/gameCard.dart';
import 'package:opengoalz/models/game/gameDetailsTab.dart';
import 'package:opengoalz/models/game/gameStatsTab.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/models/teamcomp/teamComp_main_widget.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  final int idGame;
  final int? idSelectedClub;
  const GamePage({Key? key, required this.idGame, this.idSelectedClub})
      : super(key: key);

  static Route<void> route(int idGame, int? idSelectedClub) {
    return MaterialPageRoute(
      builder: (context) =>
          GamePage(idGame: idGame, idSelectedClub: idSelectedClub),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<GamePage> {
  late Future<Game> _gameFuture;
  late final Profile currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = Provider.of<UserSessionProvider>(context, listen: false).user;

    _gameFuture = _fetchGameData();
  }

  Future<Game> _fetchGameData() async {
    final gameData =
        await supabase.from('games').select().eq('id', widget.idGame).single();
    final game = Game.fromMap(gameData, widget.idSelectedClub);

    final descriptionData = await supabase
        .from('games_description')
        .select()
        .eq('id', game.idDescription)
        .single();
    game.description = descriptionData['description'];

    if (game.idClubLeft != null) {
      final leftClubData = await supabase
          .from('clubs')
          .select()
          .eq('id', game.idClubLeft!)
          .single();
      game.leftClub = Club.fromMap(leftClubData);

      final teamcompData = await supabase
          .from('games_teamcomp')
          .select()
          .eq('id_club', game.idClubLeft!)
          .eq('season_number', game.seasonNumber)
          .eq('week_number', game.weekNumber)
          .single();

      game.leftClub.teamComps.add(TeamComp.fromMap(teamcompData));
    }

    if (game.idClubRight != null) {
      final rightClubData = await supabase
          .from('clubs')
          .select()
          .eq('id', game.idClubRight!)
          .single();
      game.rightClub = Club.fromMap(rightClubData);

      final teamcompData = await supabase
          .from('games_teamcomp')
          .select()
          .eq('id_club', game.idClubRight!)
          .eq('season_number', game.seasonNumber)
          .eq('week_number', game.weekNumber)
          .single();

      game.rightClub.teamComps.add(TeamComp.fromMap(teamcompData));
    }

    final eventsData = await supabase
        .from('game_events')
        .select()
        .eq('id_game', widget.idGame);
    game.events =
        eventsData.map<GameEvent>((map) => GameEvent.fromMap(map)).toList();

    final playerIds = [
      ...game.leftClub.teamComps.first
          .playersIdToListOfInt()
          .where((id) => id != null)
          .cast<int>(),
      ...game.rightClub.teamComps.first
          .playersIdToListOfInt()
          .where((id) => id != null)
          .cast<int>()
    ];

    final playersData =
        await supabase.from('players').select().inFilter('id', playerIds);
    final players = playersData
        .map<Player>((map) => Player.fromMap(map, currentUser))
        .toList();

    game.leftClub.teamComps.first.initPlayers(
        players.where((player) => player.idClub == game.idClubLeft).toList());
    game.rightClub.teamComps.first.initPlayers(
        players.where((player) => player.idClub == game.idClubRight).toList());

    for (GameEvent event in game.events) {
      if (event.idPlayer != null) {
        event.player =
            players.firstWhere((player) => player.id == event.idPlayer);
      }
      if (event.idPlayer2 != null) {
        event.player2 =
            players.firstWhere((player) => player.id == event.idPlayer2);
      }
      if (event.idPlayer3 != null) {
        event.player3 =
            players.firstWhere((player) => player.id == event.idPlayer3);
      }
    }

    final eventTypeIds = game.events.map((event) => event.idEventType).toList();
    final eventTypeData = await supabase
        .from('game_events_type')
        .select()
        .inFilter('id', eventTypeIds);
    final eventTypeMap = {
      for (var map in eventTypeData) map['id']: map['description']
    };

    for (GameEvent event in game.events) {
      event.description =
          eventTypeMap[event.idEventType] ?? 'ERROR: Description not found';
    }

    return game;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Game>(
        future: _gameFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading game...');
          } else if (snapshot.hasError) {
            return Center(
              child: Text('ERROR: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data available'),
            );
          } else {
            final Game game = snapshot.data!;

            return Scaffold(
              appBar: AppBar(
                title: game.getGameResultRow(context),
                leading: goBackIconButton(context),
              ),
              body: Center(
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: 600), // Set your desired maximum width
                  child: DefaultTabController(
                      length: 3, // Number of tabs
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabBar(
                            tabs: [
                              buildTabWithIcon(
                                  icon: Icons.preview, text: 'Details'),
                              buildTabWithIcon(
                                  icon: Icons.group, text: 'Teams'),
                              buildTabWithIcon(icon: iconStats, text: 'Stats'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _getGameDetails(context, game),
                                _getTeamCompsTab(context, game),
                                _getGameStats(context, game),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            );
          }
        });
  }

  Widget _getGameDetails(BuildContext context, Game game) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(icon: Icons.preview, text: 'Details'),
              buildTabWithIcon(icon: Icons.description, text: 'Full Report'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                /// Details of the game
                Column(
                  children: [
                    getGameCardWidget(context, game),
                    formSpacer12,
                    buildListOfEvents(
                        context,
                        game.events
                            .where((GameEvent event) =>
                                event.eventType.toUpperCase() == 'GOAL')
                            .toList(),
                        game,
                        false),
                  ],
                ),

                /// Full report of the game
                Column(
                  children: [
                    formSpacer12,
                    game.getGameResultRow(context, isSpaceEvenly: true),
                    formSpacer12,
                    buildListOfEvents(context, game.events, game, true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTeamCompsTab(BuildContext context, Game game) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(icon: Icons.join_left, text: game.leftClub.name),
              buildTabWithIcon(
                  icon: Icons.join_right, text: game.rightClub.name),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                /// Left Club TeamComp
                if (game.dateEnd == null &&
                    game.leftClub.id != currentUser.selectedClub!.id)
                  Center(
                    child: Text(
                        'Only the team manager can see the teamcomp before the game is played'),
                  )
                else
                  // game.leftClub.teamComps.first.getTeamCompWidget(context),
                  TeamCompWidget(teamComp: game.leftClub.teamComps.first),

                /// Right Club TeamComp
                if (game.dateEnd == null &&
                    game.rightClub.id != currentUser.selectedClub!.id)
                  Center(
                    child: Text(
                        'Only the team manager can see the teamcomp before the game is played'),
                  )
                else
                  // game.rightClub.teamComps.first.getTeamCompWidget(context),
                  TeamCompWidget(teamComp: game.rightClub.teamComps.first),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getGameStats(BuildContext context, Game game) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(icon: Icons.preview, text: 'Game Stats'),
              buildTabWithIcon(icon: Icons.description, text: 'Player Stats'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                /// Game stats
                gameStatsWidget(game),

                /// Players stats
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.construction, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('Work in progress',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
