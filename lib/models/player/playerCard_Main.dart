import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/playerCardGamesTab.dart';
import 'package:opengoalz/models/player/playerHistoryListTiles.dart';
import 'package:opengoalz/models/player/playerSellFireDialogBox.dart';
import 'package:opengoalz/models/player/playerStatsWidget.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/models/player/player_actions_listtiles.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerFavorite/playerFavoriteIconButton.dart';
import 'package:opengoalz/models/playerPoaching/playerPoachingIconButton.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/pages/user_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'class/player.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final int? index;
  final bool isExpanded;

  const PlayerCard(
      {Key? key,
      required this.player,
      this.index = null,
      this.isExpanded = false})
      : super(key: key);

  @override
  _PlayerCardState createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _developed = false;

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      // if (constraints.maxWidth < maxWidth / 2) {
      return _buildLarge();
    });
  }

  /// Build Large
  Widget _buildLarge() {
    final user = Provider.of<UserSessionProvider>(context, listen: false).user;

    /// Player Card
    Color playerColor = widget.player.isSelectedUserIncarnatedPlayer
        ? colorIsMine
        : widget.player.isSelectedClubPlayer
            ? colorIsSelected
            : colorDefault;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Adjust border radius as needed
        side: const BorderSide(
          color: Colors.blueGrey, // Border color
          width: 6.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title of the card
          ListTile(
            leading: CircleAvatar(
              backgroundColor: playerColor,
              child: widget.index == null
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
                  children: [
                    /// Player's name
                    widget.player.getPlayerNameToolTip(context),

                    /// If the player is embodied by a user, show the username
                    if (widget.player.userName != null)
                      IconButton(
                        tooltip: 'Embodied by: ${widget.player.userName}',
                        icon: Icon(
                          iconUser,
                          size: iconSizeSmall,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserPage(
                                userName: widget.player.userName,
                              ),
                            ),
                          );
                        },
                      ),

                    /// Show the status row of the player
                    widget.player.getStatusRow(),
                    if (widget.player.isSelectedUserIncarnatedPlayer ||
                        widget.player.isSelectedClubPlayer)
                      Row(
                        children: [
                          formSpacer3,
                          PlayerActionsWidget(
                            player: widget.player,
                            index: widget.index,
                          ),
                        ],
                      ),

                    /// Favorite icon button
                    PlayerFavoriteIconButton(player: widget.player, user: user),

                    /// Poaching icon button
                    PlayerPoachingIconButton(player: widget.player, user: user),
                  ],
                ),
                IconButton(
                  icon: Icon(_developed
                      ? Icons.expand_less
                      : Icons.expand_circle_down_outlined),
                  iconSize: iconSizeSmall,
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
                getClubNameClickable(
                    context, widget.player.club, widget.player.idClub),
                Row(
                  children: [
                    playerShirtNumberIcon(context, widget.player),
                    if (user.selectedClub!.id == widget.player.idClub)
                      formSpacer3,
                    playerSmallNotesIcon(context, widget.player),
                  ],
                ),
              ],
            ),
            // subtitle: Text(
            //   'Born: ${DateFormat('yyyy-MM-dd').format(widget.player.dateBirth)}',
            // ),
            // trailing: IconButton(
            //   icon: Icon(_developed
            //       ? Icons.expand_less
            //       : Icons.expand_circle_down_outlined),
            //   iconSize: iconSizeSmall,
            //   onPressed: () {
            //     setState(() {
            //       _developed = !_developed;
            //     });
            //   },
            // ),
          ),
          if (!_developed) widget.player.getPlayerMainInformation(context),
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
                      buildTabWithIcon(icon: iconDetails, text: 'Details'),
                      buildTabWithIcon(icon: iconTraining, text: 'Stats'),
                      buildTabWithIcon(icon: Icons.more_horiz, text: 'Others')
                    ],
                  ),
                  body: TabBarView(
                    children: [
                      /// Details tab
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.player.getPlayerMainInformation(context),
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
    );
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
          PlayerHistoryListTiles(player: player),
        ],
      ),
    ),
  );
}
