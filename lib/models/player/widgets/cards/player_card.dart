import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/others/getClubNameWidget.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/stats/playerCardGamesTab.dart';
import 'package:opengoalz/models/player/stats/player_history_timeline.dart';
import 'package:opengoalz/models/player/actions/player_actions_listtiles.dart';
import 'package:opengoalz/models/player/widgets/list_tiles/player_contract_duration_listtile.dart';
import 'package:opengoalz/models/player/embodied/player_embodied_listtile.dart';
import 'package:opengoalz/models/player/widgets/player_stats_widget.dart';
import 'package:opengoalz/models/player/widgets/player_widgets.dart';
import 'package:opengoalz/models/playerFavorite/playerFavoriteIconButton.dart';
import 'package:opengoalz/models/playerPoaching/playerPoachingIconButton.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'package:opengoalz/models/player/widgets/player_name_tooltip.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/player/pages/players_page.dart';
import 'package:opengoalz/models/player/widgets/embodied_user_icon_button.dart';
import 'package:opengoalz/models/player/widgets/player_status_row.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final int?
      index; // Index for displaying in list view. When null, implies only one single player is displayed on the page
  final bool isExpanded; // Whether the card is expanded to show more details
  final bool
      isReturningPlayer; // Whether the player card is for a returning player (e.g., from a search result)

  const PlayerCard({
    Key? key,
    required this.player,
    this.index = null,
    this.isExpanded = false,
    this.isReturningPlayer = false,
  }) : super(key: key);

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _developed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _developed = widget.isExpanded;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleHoverChange(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  /// Determines the tap behavior for the player card based on context
  ///
  /// Returns null if no tap action should be available, otherwise returns
  /// a callback that handles navigation based on the card's purpose:
  /// - Returning player: Pops the current screen and returns the selected player
  /// - List item: Navigates to detailed player view
  /// - Single expanded view: No tap action (already viewing details)
  VoidCallback? _getPlayerTapHandler() {
    // Case 1: Returning player scenario (e.g., player selection dialog)
    // User taps to select this player and return it to the previous screen
    if (widget.isReturningPlayer) {
      return () => Navigator.of(context).pop(widget.player);
    }

    // Case 2: Player list item with index (not expanded view)
    // User taps to navigate to detailed player page
    if (widget.index != null) {
      return () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayersPage(
              playerSearchCriterias: PlayerSearchCriterias(
                idPlayer: [widget.player.id],
              ),
            ),
          ),
        );
      };
    }

    // Case 3: Single expanded player view (index is null and not returning)
    // No tap action needed as user is already viewing the player details
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserSessionProvider>(context, listen: false).user;

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      /// Player Card
      Color playerColor = widget.player.isEmbodiedByCurrentUser
          ? colorIsMine
          : widget.player.isPartOfClubOfCurrentUser
              ? colorIsSelected
              : colorDefault;
      return MouseRegion(
        onEnter: (_) => _handleHoverChange(true),
        onExit: (_) => _handleHoverChange(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: _isHovered
              ? Matrix4.translationValues(0, -3, 0) // Subtle lift on hover
              : Matrix4.identity(),
          child: InkWell(
            onTap: _getPlayerTapHandler(),
            hoverColor: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            child: Card(
              elevation: _isHovered ? 8.0 : 4.0, // Enhanced shadow on hover

              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12), // Adjust border radius as needed
                side: BorderSide(
                  color: _isHovered // Change border color on hover
                      ? Colors.green
                      : Colors.blueGrey,
                  width:
                      _isHovered ? 6.0 : 4.0, // Border width changes on hover
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title of the card
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: playerColor,
                      child: (widget.index == null || _isHovered)
                          ? Icon(widget.player.getPlayerIcon())
                          : Text(
                              (widget.index!).toString(),
                            ),
                    ),
                    shape: shapePersoRoundedBorder(),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          /// On the left side of the card, display the player's name,
                          /// status row, actions, and favorite/poaching icons
                          /// On the right side, display the expand icon button
                          children: [
                            /// Player's name
                            // widget.player.getPlayerNameToolTip(context),
                            PlayerNameTooltip(player: widget.player),

                            /// If the player is embodied by a user, show the username
                            if (widget.player.userName != null)
                              EmbodiedUserIconButton(
                                userName: widget.player.userName!,
                              ),

                            /// Show the status row of the player
                            PlayerStatusRow(player: widget.player),

                            /// Player actions widget (list of actions on player)
                            PlayerActionsWidget(
                              player: widget.player,
                              index: widget.index,
                            ),

                            /// Favorite icon button
                            PlayerFavoriteIconButton(
                                player: widget.player, user: user),

                            /// Poaching icon button
                            PlayerPoachingIconButton(
                                player: widget.player, user: user),
                          ],
                        ),

                        /// Expand icon button to show more details
                        IconButton(
                          icon: Icon(_developed
                              ? Icons.expand_less
                              : Icons.expand_circle_down_outlined),
                          iconSize: iconSizeSmall,
                          color: Colors.green,
                          onPressed: () {
                            setState(() {
                              _developed = !_developed;
                            });
                          },
                        ),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClubNameClickable(
                          club: widget.player.club,
                          idClub: widget.player.idClub,
                        ),
                        Row(
                          children: [
                            /// Player's shirt number icon
                            PlayerShirtNumberIcon(player: widget.player),

                            /// If the user is the owner of the club
                            if (user.selectedClub!.id == widget.player.idClub)
                              PlayerSmallNotesIcon(player: widget.player),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!_developed)
                    widget.player.getPlayerMainInformation(context),
                  if (_developed)
                    SizedBox(
                      width: double.infinity,
                      // height: 400, // Adjust the height as needed
                      height: MediaQuery.of(context).size.height -
                          kToolbarHeight -
                          120, // Adjust the height as needed
                      child: DefaultTabController(
                        length: 3,
                        child: Scaffold(
                          appBar: TabBar(
                            tabs: [
                              buildTabWithIcon(
                                  icon: iconDetails, text: 'Details'),
                              buildTabWithIcon(
                                  icon: iconTraining, text: 'Stats'),
                              buildTabWithIcon(
                                  icon: Icons.more_horiz, text: 'Others')
                            ],
                          ),
                          body: TabBarView(
                            children: [
                              /// Details tab
                              SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Player's main information
                                    widget.player
                                        .getPlayerMainInformation(context),

                                    /// ListTile to display only when expended
                                    if (_developed) ...[
                                      if (widget.player.userName != null)

                                        /// Players embodied listtile
                                        PlayerCardEmbodiedListTile(
                                            player: widget.player),

                                      /// Player's end contract list tile
                                      if (widget.player.dateEndContract != null)
                                        PlayerCardContractDurationListTile(
                                            player: widget.player),
                                    ]
                                  ],
                                ),
                              ),

                              /// Stats Tab
                              PlayerCardStatsWidget(player: widget.player),

                              PlayerCardOtherTab(widget.player)
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

Widget PlayerCardOtherTab(Player player) {
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: TabBar(
        tabs: [
          buildTabWithIcon(icon: iconGames, text: 'Games'),
          buildTabWithIcon(icon: iconHistory, text: 'History'),
        ],
      ),
      body: TabBarView(
        children: [
          PlayerGamesTab(player),
          PlayerHistoryTimeline(player: player),
        ],
      ),
    ),
  );
}
