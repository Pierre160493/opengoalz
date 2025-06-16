import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/game/class/game.dart';
import 'package:opengoalz/models/league/league.dart';
import 'package:opengoalz/widgets/continent_display_widget.dart';
import 'package:opengoalz/widgets/error_with_back_button.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
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
      Colors.yellow,
      Colors.grey,
      Colors.brown,
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

  List<List<num>> _prepareChartData() {
    Map<int, List<int>> clubPositionsByWeek = {};

    // Initialize data structure for each club
    for (var club in widget.league.clubsLeague) {
      clubPositionsByWeek[club.id] = List.filled(_maxWeeks + 1, 0);
    }

    // Fill in position data
    for (var record in _clubsHistoryData) {
      int clubId = record['id_club'];
      int week = record['week_number'];
      int position = record['pos_league'];

      if (clubPositionsByWeek.containsKey(clubId) && week <= _maxWeeks) {
        clubPositionsByWeek[clubId]![week] = position;
      }
    }

    // Convert to format needed for chart
    List<List<num>> chartData = [];
    for (var club in widget.league.clubsLeague) {
      List<num> positions = List<num>.from(clubPositionsByWeek[club.id]!);

      // Fill in missing values at the beginning (week 0 positions)
      if (positions[0] == 0) {
        positions[0] = club.clubData.posLeague;
      }

      // Fill in any other zeros with the previous week's position
      for (int i = 1; i < positions.length; i++) {
        if (positions[i] == 0) {
          positions[i] = positions[i - 1];
        }
      }

      chartData.add(positions);
    }

    return chartData;
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

    // Prepare data for chart
    final chartData = ChartData(
      title: 'League Position Evolution',
      yValues: _prepareChartData(),
      typeXAxis: XAxisType.weekHistory,
      // For positions, lower is better, so we invert min/max
      minY: 1, // Top position
      // maxY: widget.league.clubsLeague.length, // Bottom position
      maxY: 6, // Bottom position
    );

    return Column(
      children: [
        Expanded(
          child: ChartDialogBox(chartData: chartData),
        ),

        // Legend for clubs
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.league.clubsLeague.length,
            itemBuilder: (context, index) {
              final club = widget.league.clubsLeague[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: _clubColors[club.id],
                    ),
                    SizedBox(width: 4),
                    club.getClubNameClickable(context),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
