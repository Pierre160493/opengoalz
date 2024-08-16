part of 'teamComp.dart';

extension TeamCompWidget on TeamComp {
  Widget getMainTeamCompWidget(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs for the inner TabController
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(Icons.preview, 'TeamComp'),
              buildTabWithIcon(Icons.reviews, 'Orders (${subs.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                getTeamCompWidget(context),
                getOrdersWidget(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
