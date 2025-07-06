import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/player/dialogs/playerSearchDialogBox.dart';
import 'package:opengoalz/models/player/widgets/cards/player_card_main.dart';
import 'package:opengoalz/models/player/widgets/player_embodied_offers_button.dart';
import 'package:opengoalz/models/player/widgets/player_user_points_button.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/player_sort_button.dart';
import 'package:provider/provider.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import '../class/player.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:opengoalz/models/player/services/player_service.dart';
import 'package:opengoalz/models/player/widgets/player_name_tooltip.dart';

class PlayersPage extends StatefulWidget {
  final PlayerSearchCriterias playerSearchCriterias;
  final bool isReturningPlayer;

  const PlayersPage(
      {Key? key,
      required this.playerSearchCriterias,
      this.isReturningPlayer = false})
      : super(key: key);

  static Route<void> route(
      Profile user, PlayerSearchCriterias playerSearchCriterias) {
    return MaterialPageRoute(
      builder: (context) =>
          PlayersPage(playerSearchCriterias: playerSearchCriterias),
    );
  }

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final PlayerService _playerService = PlayerService();
  late Stream<List<Player>> _playerStream;
  late PlayerSearchCriterias _currentSearchCriterias;
  bool _hideRemovedPlayers = true;

  @override
  void initState() {
    super.initState();
    _currentSearchCriterias = widget.playerSearchCriterias;
    _playerStream = Stream.empty();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserSessionProvider>(context, listen: false).user;
    _initializeStreams(user);
  }

  void _initializeStreams(Profile user) {
    setState(() {
      _playerStream =
          _playerService.getPlayersStream(_currentSearchCriterias, user);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionProvider>(
      builder: (context, userSessionProvider, child) {
        Profile user = userSessionProvider.user;
        return StreamBuilder<List<Player>>(
          stream: _playerStream,
          builder: (context, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return loadingCircularAndText('Loading players...');
            } else if (streamSnapshot.hasError) {
              return ErrorWithBackButton(
                  errorMessage: streamSnapshot.error.toString());
            } else {
              final List<Player> players = streamSnapshot.data ?? [];
              if (widget.playerSearchCriterias.idPlayerRemove.isNotEmpty) {
                if (_hideRemovedPlayers) {
                  players.removeWhere((player) => widget
                      .playerSearchCriterias.idPlayerRemove
                      .contains(player.id));
                }
              }
              return _buildPlayersList(user, players);
            }
          },
        );
      },
    );
  }

  Widget _buildPlayersList(Profile user, List<Player> players) {
    return Scaffold(
        appBar: AppBar(
          title: players.isEmpty
              ? Text('No Players Found')
              : players.length == 1
                  ? PlayerNameTooltip(player: players.first)
                  : Text(
                      '${players.length} Players',
                    ),
          leading: goBackIconButton(context),
          actions: [
            /// Show/Hide removed players
            if (widget.playerSearchCriterias.idPlayerRemove.isNotEmpty)
              IconButton(
                tooltip: 'Show/Hide removed players',
                onPressed: () {
                  setState(() {
                    _hideRemovedPlayers = !_hideRemovedPlayers;
                  });
                },
                icon: Icon(
                    _hideRemovedPlayers
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.green),
              ),

            /// If the page contains only one player, display additional buttons
            if (players.length == 1) ...[
              /// Button to increase the player's stats
              if (players[0].isEmbodiedByCurrentUser)
                PlayerUserPointsButton(player: players[0]),

              /// Button to place an offer for an embodied player
              if (players.length == 1 && players[0].userName != null)
                PlayerEmbodiedOffersButton(player: players[0]),
            ],

            /// Modify search criterias
            IconButton(
              tooltip: 'Modify Search Criterias',
              onPressed: () {
                showDialog<PlayerSearchCriterias>(
                  context: context,
                  builder: (BuildContext context) {
                    return playerSearchDialogBox(
                      inputPlayerSearchCriterias: _currentSearchCriterias,
                    );
                  },
                ).then((playerSearchCriterias) {
                  if (playerSearchCriterias != null) {
                    setState(() {
                      _currentSearchCriterias = playerSearchCriterias;
                      _initializeStreams(user);
                    });
                  }
                });
              },
              icon: Icon(Icons.person_search, color: Colors.green),
            ),

            /// Sort players
            PlayerSortButton(
              players: players,
              onSort: () => setState(() {}),
            ),
          ],
        ),
        drawer: (widget.isReturningPlayer || players.length == 1)
            ? null
            : const AppDrawer(),
        body: MaxWidthContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final Player player = players[index];
                    return InkWell(
                      onTap: widget.isReturningPlayer || players.length > 1
                          ? () {
                              if (widget.isReturningPlayer) {
                                Navigator.of(context).pop(player);
                              } else if (players.length > 1) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayersPage(
                                      playerSearchCriterias:
                                          PlayerSearchCriterias(
                                        idPlayer: [player.id],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: PlayerCard(
                          player: player,
                          index: players.length == 1 ? null : index + 1,
                          isExpanded: players.length == 1 ? true : false),
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
