import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/models/teamcomp/teamCompTab.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';

Widget TeamCompMainTab(
    BuildContext context, Profile currentUser, TeamComp? teamcomp) {
  if (teamcomp == null) {
    return Center(
      child: Text('No teamcomp found'),
    );
  }
  return DefaultTabController(
    length: 2, // Number of tabs for the inner TabController
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          tabs: [
            /// Teamcomp tab
            buildTabWithIcon(
              icon: iconTeamComp,
              iconColor: teamcomp.errors == null ? Colors.green : Colors.red,
              text: 'TeamComp',
            ),

            /// Orders tab
            buildTabWithIcon(
                icon: Icons.multiple_stop,
                text: 'Orders (${teamcomp.subs.length})'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              /// Teamcomp tab
              TeamCompTab(teamcomp: teamcomp),

              /// Orders tab
              teamcomp.getOrdersWidget(context),
            ],
          ),
        ),
      ],
    ),
  );
}
