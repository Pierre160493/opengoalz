import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';

class TeamCompWidget extends StatefulWidget {
  final TeamComp teamComp;

  TeamCompWidget({required this.teamComp});

  @override
  _TeamCompWidgetState createState() => _TeamCompWidgetState();
}

class _TeamCompWidgetState extends State<TeamCompWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs for the inner TabController
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon2(
                context,
                Row(
                  children: [
                    Icon(
                      iconTeamComp,
                      color: widget.teamComp.errors == null ? null : Colors.red,
                    ),
                    SizedBox(width: 3),
                    Text('TeamComp'),
                  ],
                ),
              ),
              buildTabWithIcon(Icons.multiple_stop,
                  'Orders (${widget.teamComp.subs.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                widget.teamComp.getTeamCompWidget(context),
                widget.teamComp.getOrdersWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// part of 'teamComp.dart';

// extension TeamCompWidget on TeamComp {
//   Widget getMainTeamCompWidget(BuildContext context) {
//     return DefaultTabController(
//       length: 2, // Number of tabs for the inner TabController
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TabBar(
//             tabs: [
//               buildTabWithIcon(Icons.preview, 'TeamComp'),
//               buildTabWithIcon(Icons.multiple_stop, 'Orders (${subs.length})'),
//             ],
//           ),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 getTeamCompWidget(context),
//                 getOrdersWidget(context),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
