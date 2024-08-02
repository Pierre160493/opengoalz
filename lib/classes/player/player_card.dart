import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'class/player.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final int number;
  final bool isExpanded;

  const PlayerCard(
      {Key? key,
      required this.player,
      required this.number,
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
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Text(
                  (widget.number).toString(),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    '${widget.player.firstName[0]}.${widget.player.lastName.toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  widget.player.getStatusRow(),
                  if (widget.player.idClub ==
                      Provider.of<SessionProvider>(context, listen: false)
                          .user!
                          .selectedClub
                          .id)
                    Row(
                      children: [
                        SizedBox(width: 6.0),
                        widget.player
                            .playerPopUpMenuItem(context, widget.number),
                      ],
                    )
                ],
              ),
              // subtitle: Text(
              //   'Born: ${DateFormat('yyyy-MM-dd').format(widget.player.dateBirth)}',
              // ),
              trailing: IconButton(
                icon: Icon(_developed
                    ? Icons.expand_less
                    : Icons.expand_circle_down_outlined),
                iconSize: iconSizeMedium,
                onPressed: () {
                  setState(() {
                    _developed = !_developed;
                  });
                },
              ),
            ),
            if (!_developed) widget.player.getPlayerMainInformation(context),
            const SizedBox(height: 6.0),
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
      ),
    );
  }
}
