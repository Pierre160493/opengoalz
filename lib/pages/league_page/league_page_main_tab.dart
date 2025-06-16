import 'package:flutter/material.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/pages/league_page/current_ranking_tab.dart';
import 'package:opengoalz/pages/league_page/evolution_ranking_tab.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';

class LeaguePageMainTab extends StatelessWidget {
  final League league;
  final int? selectedSeason;
  final bool isReturningBotClub;

  const LeaguePageMainTab({
    Key? key,
    required this.league,
    this.selectedSeason,
    this.isReturningBotClub = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              buildTabWithIcon(icon: Icons.more_time, text: 'Current'),
              buildTabWithIcon(icon: Icons.ssid_chart, text: 'Evolution'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                CurrentRankingTab(
                  league: league,
                  isReturningBotClub: isReturningBotClub,
                ),
                EvolutionRankingTab(
                  league: league,
                  isReturningBotClub: isReturningBotClub,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
