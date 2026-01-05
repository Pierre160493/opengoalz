import 'dart:async';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/dialogs/playerSearchDialogBox.dart';
import 'package:opengoalz/models/player/widgets/cards/player_card.dart';
import 'package:opengoalz/models/player/widgets/player_embodied_offers_button.dart';
import 'package:opengoalz/models/player/widgets/player_user_points_button.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/goBack_tool_tip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/player_sort_button.dart';
import 'package:provider/provider.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
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

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final PlayerService _playerService = PlayerService();
  late Future<List<int>> _playerIdsFuture;
  late PlayerSearchCriterias _currentSearchCriterias;
  bool _hideRemovedPlayers = true;
  Timer? _refreshTimer;
  bool _hasUpdates = false;
  List<int> _currentPlayerIds = [];

  @override
  void initState() {
    super.initState();
    print('PlayersPage: initState');
    _currentSearchCriterias = widget.playerSearchCriterias;
    _initializeFuture();
    _startRefreshTimer();
  }

  void _initializeFuture() {
    if (!mounted) return;
    print('PlayersPage: _initializeFuture called.');
    setState(() {
      _hasUpdates = false;
      _playerIdsFuture = _currentSearchCriterias.fetchPlayerIds();
      _playerIdsFuture.then((ids) {
        print('PlayersPage: Fetched initial player IDs: ${ids.length}');
        if (mounted) {
          setState(() {
            _currentPlayerIds = ids;
          });
        }
      });
    });
  }

  void _startRefreshTimer() {
    print('PlayersPage: Starting refresh timer.');
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      print('PlayersPage: Refresh timer fired.');

      try {
        final newPlayerIds = await _currentSearchCriterias.fetchPlayerIds();
        if (!mounted) return;

        print(
            'PlayersPage: Checked for updates. Current IDs: ${_currentPlayerIds.length}, Found IDs: ${newPlayerIds.length}');

        // Early return if lengths differ (most common case)
        if (_currentPlayerIds.length != newPlayerIds.length) {
          print(
              'PlayersPage: Player list size changed. Showing update indicator.');
          setState(() {
            _hasUpdates = true;
          });
          return;
        }

        // Use ListEquality for more efficient comparison
        if (!const ListEquality().equals(_currentPlayerIds, newPlayerIds)) {
          print(
              'PlayersPage: Player list content changed. Showing update indicator.');
          setState(() {
            _hasUpdates = true;
          });
        }
      } catch (error) {
        print('PlayersPage: Error checking for updates: $error');
        // Optionally handle the error (e.g., show a message to the user)
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Profile user =
        Provider.of<UserSessionProvider>(context, listen: false).user;
    print('PlayersPage: build');
    return FutureBuilder<List<int>>(
      future: _playerIdsFuture,
      builder: (context, futureSnapshot) {
        print(
            'PlayersPage: FutureBuilder state: ${futureSnapshot.connectionState}');
        if (futureSnapshot.connectionState == ConnectionState.waiting) {
          return loadingCircularAndText('Finding players...');
        }

        if (futureSnapshot.hasError) {
          print('PlayersPage: FutureBuilder error: ${futureSnapshot.error}');
          return ErrorWithBackButton(
              errorMessage: futureSnapshot.error.toString());
        }

        final playerIds = futureSnapshot.data ?? [];
        print(
            'PlayersPage: FutureBuilder success. Player IDs count: ${playerIds.length}');

        if (playerIds.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text('No Players Found',
                  style: TextStyle(fontSize: fontSizeLarge)),
              leading: goBackIconButton(context),
              actions: [
                if (_hasUpdates)
                  IconButton(
                    tooltip: 'Refresh players',
                    onPressed: _initializeFuture,
                    icon: Icon(Icons.refresh, color: Colors.blue),
                  ),
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
                        _currentSearchCriterias = playerSearchCriterias;
                        _initializeFuture();
                      }
                    });
                  },
                  icon: Icon(Icons.person_search, color: Colors.green),
                ),
              ],
            ),
            drawer: widget.isReturningPlayer ? null : const AppDrawer(),
            body: Center(
                child: Text(
              'No players match the criteria.',
              style: TextStyle(fontSize: fontSizeMedium),
            )),
          );
        }

        return StreamBuilder<List<Player>>(
          stream: _playerService.getPlayersStream(
              playerIds, _currentSearchCriterias, user),
          builder: (context, streamSnapshot) {
            print(
                'PlayersPage: StreamBuilder state: ${streamSnapshot.connectionState}');
            if (streamSnapshot.connectionState == ConnectionState.waiting &&
                !streamSnapshot.hasData) {
              return loadingCircularAndText('Loading players...');
            }

            if (streamSnapshot.hasError) {
              print(
                  'PlayersPage: StreamBuilder error: ${streamSnapshot.error}');
            }

            final players = streamSnapshot.data ?? [];
            print(
                'PlayersPage: StreamBuilder data. Players count: ${players.length}');
            if (widget.playerSearchCriterias.idPlayerRemove.isNotEmpty &&
                _hideRemovedPlayers) {
              players.removeWhere((player) => widget
                  .playerSearchCriterias.idPlayerRemove
                  .contains(player.id));
            }

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
                  if (_hasUpdates)
                    IconButton(
                      tooltip: 'Refresh players',
                      onPressed: _initializeFuture,
                      icon: Icon(Icons.refresh, color: Colors.blue),
                    ),
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
                  if (players.length == 1) ...[
                    if (players[0].isEmbodiedByCurrentUser)
                      PlayerUserPointsButton(player: players[0]),
                    if (players.length == 1 && players[0].userName != null)
                      PlayerEmbodiedOffersButton(player: players[0]),
                  ],
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
                          _currentSearchCriterias = playerSearchCriterias;
                          _initializeFuture();
                        }
                      });
                    },
                    icon: Icon(Icons.person_search, color: Colors.green),
                  ),
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
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final Player player = players[index];
                    return PlayerCard(
                      player: player,
                      index: players.length == 1 ? null : index + 1,
                      isExpanded: players.length == 1 ? true : false,
                      isReturningPlayer: widget.isReturningPlayer,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
