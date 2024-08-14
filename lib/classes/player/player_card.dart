import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club/getClubNameWidget.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/multiverse_row_widget.dart';
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
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => PlayersPage(
            //         inputCriteria: {
            //           'Players': [widget.player.id]
            //         },
            //       ),
            //     ),
            //   );
            // },
            leading: CircleAvatar(
              backgroundColor: (Provider.of<SessionProvider>(context)
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
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12), // Adjust border radius as needed
              side: const BorderSide(
                color: Colors.blueGrey, // Border color
                width: 2.0,
              ),
            ),
            title: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.player.getPlayerNames(context),
                widget.player.getStatusRow(),
                if (Provider.of<SessionProvider>(context).user!.players.any(
                        (Player player) => player.id == widget.player.id) ||
                    Provider.of<SessionProvider>(context)
                            .user!
                            .selectedClub
                            .id ==
                        widget.player.idClub)
                  Row(
                    children: [
                      SizedBox(width: 3.0),
                      widget.player.playerPopUpMenuItem(context, widget.index),
                    ],
                  )
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getClubNameClickable(
                    context, widget.player.club, widget.player.idClub),
                multiverseWidget(widget.player.multiverseSpeed),
              ],
            ),
            // subtitle: Text(
            //   'Born: ${DateFormat('yyyy-MM-dd').format(widget.player.dateBirth)}',
            // ),
            trailing: IconButton(
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
                length: 4,
                child: Scaffold(
                  appBar: TabBar(
                    tabs: [
                      buildTabWithIcon(iconDetails, 'Details'),
                      buildTabWithIcon(iconTraining, 'Stats'),
                      buildTabWithIcon(iconGames, 'Games'),
                      buildTabWithIcon(iconHistory, 'History')
                    ],
                  ),
                  body: TabBarView(
                    children: [
                      /// Details tab
                      widget.player.playerCardDetailsWidget(context),

                      /// Stats Tab
                      widget.player.playerCardStatsWidget(context),

                      /// Games tab
                      Placeholder(),

                      /// History tab
                      widget.player.playerCardStatsWidget(context),
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
