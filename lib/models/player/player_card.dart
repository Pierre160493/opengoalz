import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/multiverse/multiverseWidgets.dart';
import 'package:opengoalz/models/player/playerHistoryWidget.dart';
import 'package:opengoalz/models/player/playerStatsWidget.dart';
import 'package:opengoalz/models/player/playerWidgets.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/countryListTile.dart';
import 'package:opengoalz/widgets/playersNotes.dart';
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
      if (constraints.maxWidth < maxWidth / 2) {
        return _buildSmall();
      } else {
        return _buildLarge();
        // return _buildSmall();
      }
    });
  }

  /// Build Large
  Widget _buildLarge() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Adjust border radius as needed
        side: const BorderSide(
          color: Colors.blueGrey, // Border color
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: (Provider.of<SessionProvider>(context,
                          listen: false)
                      .user!
                      .players
                      .any((Player player) => player.id == widget.player.id))
                  ? Colors.purple
                  : null,
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
                    widget.player.getPlayerNameToolTip(context),
                    widget.player.getStatusRow(),
                    if (Provider.of<SessionProvider>(context, listen: false)
                            .user!
                            .players
                            .any((Player player) =>
                                player.id == widget.player.id) ||
                        Provider.of<SessionProvider>(context, listen: false)
                                .user!
                                .selectedClub!
                                .id ==
                            widget.player.idClub)
                      Row(
                        children: [
                          SizedBox(width: 3.0),
                          widget.player
                              .playerPopUpMenuItem(context, widget.index),
                        ],
                      ),
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
                    if (Provider.of<SessionProvider>(context, listen: false)
                            .user!
                            .selectedClub!
                            .id ==
                        widget.player.idClub)
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
                      buildTabWithIcon(iconDetails, 'Details'),
                      buildTabWithIcon(iconTraining, 'Stats'),
                      // buildTabWithIcon(iconGames, 'Games'),
                      buildTabWithIcon(Icons.more_horiz, 'Others')
                    ],
                  ),
                  body: TabBarView(
                    children: [
                      /// Details tab
                      // widget.player.playerCardDetailsWidget(context),
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

                      /// Games tab
                      // Placeholder(),

                      /// History tab
                      // widget.player.playerCardStatsWidget(context),
                      // PostItNote(player: widget.player),
                      PlayerOtherTab()
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmall() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12), // Adjust border radius as needed
        side: const BorderSide(
          color: Colors.blueGrey, // Border color
          width: 3.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            shape: shapePersoRoundedBorder(),
            title: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: (Provider.of<SessionProvider>(context,
                              listen: false)
                          .user!
                          .players
                          .any(
                              (Player player) => player.id == widget.player.id))
                      ? Colors.purple
                      : null,
                  child: widget.index == null
                      ? Icon(widget.player.getPlayerIcon())
                      : Text(
                          (widget.index!).toString(),
                        ),
                ),
                widget.player.getPlayerNameToolTip(context),
                widget.player.getStatusRow(),
                if (Provider.of<SessionProvider>(context, listen: false)
                        .user!
                        .players
                        .any(
                            (Player player) => player.id == widget.player.id) ||
                    Provider.of<SessionProvider>(context, listen: false)
                            .user!
                            .selectedClub!
                            .id ==
                        widget.player.idClub)
                  Row(
                    children: [
                      SizedBox(width: 3.0),
                      widget.player.playerPopUpMenuItem(context, widget.index),
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
                  )
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getClubNameClickable(
                    context, widget.player.club, widget.player.idClub),
                getMultiverseIconFromId_Clickable(
                    context, widget.player.idMultiverse),
              ],
            ),
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
                      buildTabWithIcon(iconDetails, 'Details'),
                      buildTabWithIcon(iconTraining, 'Stats'),
                      buildTabWithIcon(Icons.more_horiz, 'Others')
                    ],
                  ),
                  body: TabBarView(
                    children: [
                      /// Details tab
                      // widget.player.playerCardDetailsWidget(context),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getAgeListTile(widget.player),
                            getCountryListTile(
                                context, widget.player.idCountry),
                            widget.player.getPerformanceScoreListTile(context),
                            widget.player.getExpensesWidget(context),
                            // if (widget.player.transferBids.length > 0 &&
                            //     widget.player.dateBidEnd!
                            //         .isAfter(DateTime.now()))
                            //   widget.player.playerTransferWidget(context),
                            if (widget.player.dateEndInjury != null)
                              widget.player.getInjuryWidget(),
                          ],
                        ),
                      ),

                      /// Stats Tab
                      PlayerCardStatsWidget(player: widget.player),

                      /// Games tab
                      // Placeholder(),

                      /// Others tab
                      // widget.player.playerCardStatsWidget(context),
                      // PostItNote(player: widget.player),
                      PlayerOtherTab()
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget PlayerOtherTab() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            buildTabWithIcon(iconGames, 'Games'),
            buildTabWithIcon(iconHistory, 'History'),
          ],
        ),
        body: TabBarView(
          children: [
            // PlayerCardStatsWidget(player: widget.player),
            PostItNote(player: widget.player),
            // Placeholder(),
            PlayerCardHistoryWidget(player: widget.player),
          ],
        ),
      ),
    );
  }
}
