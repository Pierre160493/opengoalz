import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

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
  List<Map<String, dynamic>> _clubsHistoryData = [];
  String? _errorMessage;
  Map<int, Color> _clubColors = {};
  int _maxWeeks = 0;

  // Add a list of colors for the lines (expand as needed)
  final List<Color> _lineColors = [
    colorGold, // 1st
    colorSilver, // 2nd
    colorBronze, // 3rd (bronze)
    Colors.green,
    Colors.blue,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _loadClubsHistory();
  }

  void _loadClubsHistory() {
    final clubIds = widget.league.clubsLeague.map((club) => club.id).toList();

    if (clubIds.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No clubs found in this league';
      });
      return;
    }

    // Generate distinct colors for each club
    _assignClubColors();

    supabase
        .from('clubs_history_weekly')
        .select()
        .eq('season_number', widget.league.selectedSeasonNumber!)
        .inFilter('id_club', clubIds)
        .order('week_number', ascending: true)
        .then((data) {
      setState(() {
        print(data);
        _clubsHistoryData = data;
        _isLoading = false;

        // Calculate the max week number for x-axis
        if (data.isNotEmpty) {
          _maxWeeks =
              data.map((record) => record['week_number'] as int).reduce(max);
        }
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading ranking data: $error';
      });
    });
  }

  void _assignClubColors() {
    // Define a list of distinct colors
    final List<Color> colors = [
      colorGold, // True gold color (hex for gold)
      colorSilver, // Silver color
      colorBronze, // Bronze color
      Colors.green,
      Colors.orange,
      Colors.red
    ];

    int colorIndex = 0;
    for (var club in widget.league.clubsLeague) {
      _clubColors[club.id] = colors[colorIndex % colors.length];
      colorIndex++;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return loadingCircularAndText('Loading ranking evolution data...');
    }

    if (_errorMessage != null) {
      return ErrorWithBackButton(errorMessage: _errorMessage!);
    }

    if (_clubsHistoryData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: iconSizeLarge, color: Colors.orange),
            Text('No ranking history data available for this league'),
          ],
        ),
      );
    }

    // Prepare chart data: each club's positions over weeks
    final List<List<int>> clubPositions = [];
    final List<String> clubNames = [];
    final List<int> clubIds = [];
    final int clubCount = widget.league.clubsLeague.length;

    // Map clubId to index for color assignment
    final Map<int, int> clubIdToIndex = {};
    for (int i = 0; i < widget.league.clubsLeague.length; i++) {
      clubIdToIndex[widget.league.clubsLeague[i].id] = i;
      clubNames.add(widget.league.clubsLeague[i].name);
      clubIds.add(widget.league.clubsLeague[i].id);
    }

    // Find the max week number
    int maxWeek = 0;
    if (_clubsHistoryData.isNotEmpty) {
      maxWeek = _clubsHistoryData
          .map((rec) => rec['week_number'] as int)
          .reduce((a, b) => a > b ? a : b);
    }

    // Build a map: clubId -> [positions by week]
    Map<int, List<int>> clubIdToPositions = {};
    for (var clubId in clubIds) {
      clubIdToPositions[clubId] = List.filled(maxWeek + 1, 0);
    }
    for (var rec in _clubsHistoryData) {
      int clubId = rec['id_club'];
      int week = rec['week_number'];
      int pos = rec['pos_league'];
      clubIdToPositions[clubId]![week] = pos;
    }
    // Fill missing with previous
    for (var clubId in clubIds) {
      for (int w = 1; w <= maxWeek; w++) {
        if (clubIdToPositions[clubId]![w] == 0) {
          clubIdToPositions[clubId]![w] = clubIdToPositions[clubId]![w - 1];
        }
      }
      clubPositions.add(clubIdToPositions[clubId]!);
    }

    // Medal color assignment for last week
    Map<int, Color> clubIdToMedalColor = {};
    if (maxWeek > 0) {
      // Get all clubs' last positions
      List<MapEntry<int, int>> lastWeekPositions = clubIdToPositions.entries
          .map((e) => MapEntry(e.key, e.value[maxWeek]))
          .toList();
      lastWeekPositions.sort((a, b) => a.value.compareTo(b.value));
      for (int i = 0; i < lastWeekPositions.length; i++) {
        if (i == 0) {
          clubIdToMedalColor[lastWeekPositions[i].key] = Colors.amber;
        } else if (i == 1) {
          clubIdToMedalColor[lastWeekPositions[i].key] = Colors.grey;
        } else if (i == 2) {
          clubIdToMedalColor[lastWeekPositions[i].key] = Color(0xFFcd7f32);
        }
      }
    }

    // Build the chart lines
    List<LineChartBarData> lines = [];
    for (int i = 0; i < clubPositions.length; i++) {
      final clubId = clubIds[i];
      final color =
          clubIdToMedalColor[clubId] ?? _lineColors[i % _lineColors.length];
      // Only include weeks 1..maxWeek (skip week 0)
      final spots = List.generate(
        clubPositions[i].length - 1,
        (w) {
          final week = w + 1; // shift index to start at week 1
          final invertedY = (clubCount + 1) - clubPositions[i][week];
          return FlSpot(week.toDouble(), invertedY.toDouble());
        },
      );
      lines.add(LineChartBarData(
        spots: spots,
        isCurved: false,
        dotData: FlDotData(show: true),
        aboveBarData: BarAreaData(show: false),
        color: color,
        barWidth: 3,
      ));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          formSpacer3,
          AspectRatio(
            aspectRatio: 1.7,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  lineBarsData: lines,
                  minY: 1,
                  maxY: clubCount.toDouble(),
                  titlesData: FlTitlesData(
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return Text('W0');
                          if (value == maxWeek.toDouble())
                            return Text('W$maxWeek');
                          if (value % 2 == 0) return Text('W${value.toInt()}');
                          return Container();
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
              final club = widget.league.clubsLeague[index];
              final clubId = club.id;
              final color = clubIdToMedalColor[clubId] ??
                  _lineColors[index % _lineColors.length];
              int? lastPos = clubIdToPositions[clubId] != null &&
                      clubIdToPositions[clubId]!.isNotEmpty
                  ? clubIdToPositions[clubId]![maxWeek]
                  : null;
              return ListTile(
                  leading: Container(
                    width: 16,
                    height: 16,
                    color: color,
                  ),
                  title: club.getClubNameClickable(context),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  trailing: lastPos != null ? Text('#$lastPos') : null,
                  shape: shapePersoRoundedBorder());
            },
          ),
        ],
      ),
    );
  }
}
