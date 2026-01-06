import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/class/club_history.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:fl_chart/fl_chart.dart';

class EvolutionRankingTab extends StatefulWidget {
  final League league;
  final bool isReturningBotClub;

  const EvolutionRankingTab({
    Key? key,
    required this.league,
    this.isReturningBotClub = false,
  }) : super(key: key);

  @override
  _EvolutionRankingTabState createState() => _EvolutionRankingTabState();
}

class _EvolutionRankingTabState extends State<EvolutionRankingTab> {
  bool _isLoading = true;
  String? _errorMessage;
  // Add a flag to control whether minY should be forced to 0
  bool zoomGraph = false;
  late League league;

  // // Add this static map for curve types
  static const Map<String, String> curveTypes = {
    'pos_league': 'Ranking',
    'league_points': 'League Points',
    'elo_points': 'Elo Points',
    'number_fans': 'Fans',
    // 'training_weight': 'Training Weight',
    'cash': 'Cash',
    // 'expenses_players_ratio_target': 'Players Ratio Target',
    // 'expenses_training_applied': 'Training Applied',
    'expenses_players': 'Players Expenses',
    'expenses_total': 'Total Expenses',
    // 'revenues_sponsors': 'Sponsors Revenue',
    'revenues_total': 'Total Revenue',
    // 'expenses_players_ratio': 'Players Ratio',
    // 'expenses_tax': 'Tax Expenses',
    'league_goals_for': 'Goals For',
    'league_goals_against': 'Goals Against',
    // 'expenses_training_target': 'Training Target',
    'scouts_weight': 'Scouts Weight',
    // 'expenses_scouts_target': 'Scouts Target',
    // 'expenses_scouts_applied': 'Scouts Applied',
    'expenses_transfers_done': 'Transfers Expenses',
    'revenues_transfers_done': 'Transfers Revenue',
    // 'expenses_staff': 'Staff Expenses',
  };

  String _selectedCurveType = 'pos_league';

  @override
  void initState() {
    super.initState();
    league = widget.league;
    supabase
        .from('clubs_history_weekly')
        .select()
        .eq('season_number', widget.league.selectedSeasonNumber!)
        .inFilter('id_club',
            widget.league.clubsLeague.map((Club club) => club.id).toList())
        .lte('week_number', 10)
        .order('week_number', ascending: true)
        .then((data) {
      // Map all data as a list of ClubData
      final List<ClubDataHistory> allClubDataHistory =
          (data).map((map) => ClubDataHistory.fromMap(map)).toList();

      for (ClubDataHistory ClubDataHistoryData in allClubDataHistory) {
        league.clubsLeague
            .firstWhere((club) => club.id == ClubDataHistoryData.idClub)
            .lisClubDataHistory
            .add(ClubDataHistoryData);
      }

      setState(() {
        _isLoading = false;
        // _clubsHistoryData = data;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading ranking data: $error';
        print(_errorMessage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return loadingCircularAndText('Loading ranking evolution data...');
    }

    if (_errorMessage != null) {
      return ErrorWithBackButton(errorMessage: _errorMessage!);
    }

    // Build the chart lines using league.clubsLeague and plot posLeague for each week
    List<LineChartBarData> lines = [];
    for (int i = 0; i < league.clubsLeague.length; i++) {
      final club = league.clubsLeague[i];
      final color = rankingColors[i];

      // Extract posLeague for each week from lisClubDataHistory, sorted by week
      final sortedHistory = [...club.lisClubDataHistory]
        ..sort((a, b) => a.numberWeak.compareTo(b.numberWeak));
      final spots = sortedHistory.map((history) {
        final week = history.numberWeak;
        num value = history.clubData[_selectedCurveType];
        double y = _selectedCurveType == 'pos_league'
            ? (league.clubsLeague.length + 1) - value.toDouble()
            : value.toDouble();
        return FlSpot(week.toDouble(), y);
      }).toList();

      lines.add(LineChartBarData(
        spots: spots,
        isCurved: false,
        dotData: FlDotData(show: true),
        aboveBarData: BarAreaData(show: false),
        color: color,
        barWidth: 3,
      ));
    }

    // Calculate minY and maxY dynamically based on the spots
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final line in lines) {
      for (final spot in line.spots) {
        if (spot.y < minY) minY = spot.y;
        if (spot.y > maxY) maxY = spot.y;
      }
    }

    // Ensure minY and maxY have a reasonable range if no data exists
    if (minY == double.infinity || maxY == double.negativeInfinity) {
      minY = 0;
      maxY = 1;
    }

    // Apply the flag to control minY
    if (zoomGraph == false) {
      minY = math.min(minY, 0);
    }

    // Use minY and maxY in the chart configuration
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  curveTypes[_selectedCurveType] != null
                      ? '${curveTypes[_selectedCurveType]} Evolution'
                      : 'Unknown Chart Type',
                  style: TextStyle(
                    fontSize: fontSizeMedium,
                  ),
                ),
                Tooltip(
                  message: 'Zoom Graph',
                  child: Switch(
                    value: zoomGraph,
                    onChanged: (value) {
                      setState(() {
                        zoomGraph = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              tooltip: 'Select chart type',
              icon: Icon(Icons.more_vert,
                  color: Colors.green, size: iconSizeMedium),
              onSelected: (value) {
                setState(() {
                  _selectedCurveType = value;
                });
              },
              itemBuilder: (context) => curveTypes.entries
                  .map((e) => PopupMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
            ),
          ),
          formSpacer3,
          AspectRatio(
            aspectRatio: 1.7,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: lines,
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Transform.rotate(
                            angle: -20 *
                                (math.pi /
                                    180), // Rotate text by -30 degrees for better readability
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 12),
                            ),
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 == 0) {
                            return Text('W${value.toInt()}');
                          }
                          return const SizedBox
                              .shrink(); // Hide non-integer values
                        },
                        reservedSize: 32,
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  lineTouchData: LineTouchData(enabled: true),
                ),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.league.clubsLeague.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: rankingColors[index],
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                title: league.clubsLeague[index].getClubNameClickable(context),
                dense: true,
                visualDensity: VisualDensity.compact,
                shape: shapePersoRoundedBorder(),
              );
            },
          ),
        ],
      ),
    );
  }
}
