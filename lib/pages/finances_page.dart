import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
import 'package:opengoalz/models/club/clubCashListTile.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:quiver/iterables.dart' as quiver;

class FinancesPage extends StatefulWidget {
  final Club club;
  const FinancesPage({Key? key, required this.club}) : super(key: key);

  static Route<void> route(Club club) {
    return MaterialPageRoute(
      builder: (context) =>
          FinancesPage(club: club), // Corrected parameter name
    );
  }

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  late Stream<List<ClubData>> _clubHistoryStream;
  bool _showCashCurve = true;
  bool _showRevenuesCurve = true;
  bool _showExpensesCurve = true;
  late int _selectedWeek;
  late int _selectedWeekMax;
  int? _revenuesSponsors;
  int? _revenuesTransfersDone;
  int? _expensesSalaries;
  int? _expensesStaff;
  int? _expensesScouts;
  int? _expensesTaxes;
  int? _expensesTransfersDone;
  int? _revenuesTotal;
  int? _expensesTotal;
  int? _weeklyTotal;
  List<ClubData> _clubDataHistory = [];

  @override
  void initState() {
    _clubHistoryStream =
        ClubData.streamClubDataHistory(widget.club.id).map((data) {
      _clubDataHistory = [
        widget.club.clubData,
        ...data
      ]; // Prepend current club data
      _selectedWeekMax = _clubDataHistory.length - 1;
      return _clubDataHistory;
    });

    _selectedWeek = 0;

    super.initState();
  }

  void _showChartDialog(BuildContext context, String title, List<num> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final chartData = ChartData(
          title: title,
          yValues: [data],
          typeXAxis: XAxisType.weekHistory,
        );

        return ChartDialogBox(chartData: chartData);
      },
    );
  }

  void _calculateValues(ClubData clubData) {
    // if (clubData == null) {
    //   _revenuesSponsors = null;
    //   _expensesSalaries = null;
    //   _expensesStaff = null;
    //   _expensesScouts = null;
    //   _expensesTaxes = null;
    //   _revenuesTransfersDone = null;
    //   _expensesTransfersDone = null;
    //   _revenuesTotal = null;
    //   _expensesTotal = null;
    //   _weeklyTotal = null;
    // }
    _revenuesSponsors = clubData.revenuesSponsors;
    _expensesSalaries = clubData.expensesPlayers;
    _expensesStaff = _selectedWeek == 0
        ? clubData.expensesStaffTarget
        : clubData.expensesStaffApplied;
    _expensesScouts = _selectedWeek == 0
        ? clubData.expensesScoutsTarget
        : clubData.expensesScoutsApplied;
    _expensesTaxes = _selectedWeek == 0
        ? (clubData.cash * 0.05).floor()
        : clubData.expensesTax;
    _revenuesTransfersDone = clubData.revenuesTransfersDone;
    _expensesTransfersDone = clubData.expensesTransfersDone;
    _revenuesTotal = _revenuesSponsors! + _revenuesTransfersDone!;
    _expensesTotal = _expensesSalaries! +
        _expensesStaff! +
        _expensesScouts! +
        _expensesTaxes! +
        _expensesTransfersDone!;
    _weeklyTotal = _revenuesTotal! - _expensesTotal!;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ClubData>>(
      stream: _clubHistoryStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          List<ClubData> clubDataHistory = snapshot.data!;

          /// Calculate the values to be displayed
          _calculateValues(clubDataHistory[_selectedWeekMax - _selectedWeek]);
          // Process and display the club data history as needed
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  widget.club.getClubNameClickable(context),
                  Text(' finances'),
                ],
              ),
              leading: goBackIconButton(context),
            ),
            body: MaxWidthContainer(
              child: DefaultTabController(
                length: 2, // The number of tabs
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        buildTabWithIcon(icon: iconMoney, text: 'Weekly'),
                        buildTabWithIcon(icon: iconHistory, text: 'History'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _getFinances(widget.club, clubDataHistory),
                          _getFinancesHistory(widget.club, clubDataHistory),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _getFinances(Club club, List<ClubData> clubDataHistory) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          /// Club cash
          getClubCashListTile(context, club),

          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedWeek == 0
                      ? 'Current Week'
                      : _selectedWeek == 1
                          ? 'Last week'
                          : '${_selectedWeek} weeks ago',
                ),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Previous 7 weeks',
                      icon: Icon(Icons.keyboard_double_arrow_left),
                      onPressed: _selectedWeek == _selectedWeekMax
                          ? null
                          : () {
                              setState(() {
                                _selectedWeek =
                                    min(_selectedWeekMax, _selectedWeek + 7);
                                _calculateValues(clubDataHistory[
                                    _selectedWeekMax - _selectedWeek]);
                              });
                            },
                    ),
                    IconButton(
                      tooltip: 'Previous week',
                      icon: Icon(Icons.keyboard_arrow_left),
                      onPressed: _selectedWeek == _selectedWeekMax
                          ? null
                          : () {
                              setState(() {
                                _selectedWeek =
                                    min(_selectedWeekMax, _selectedWeek + 1);
                                _calculateValues(clubDataHistory[
                                    _selectedWeekMax - _selectedWeek]);
                              });
                            },
                    ),
                    IconButton(
                      tooltip: 'Next week',
                      icon: Icon(Icons.keyboard_arrow_right),
                      onPressed: _selectedWeek == 0
                          ? null
                          : () {
                              setState(() {
                                _selectedWeek = max(0, _selectedWeek - 1);
                                _calculateValues(clubDataHistory[
                                    _selectedWeekMax - _selectedWeek]);
                              });
                            },
                    ),
                    IconButton(
                      tooltip: 'Next 7 weeks',
                      icon: Icon(Icons.keyboard_double_arrow_right),
                      onPressed: _selectedWeek == 0
                          ? null
                          : () {
                              setState(() {
                                _selectedWeek = max(0, _selectedWeek - 7);
                                _calculateValues(clubDataHistory[
                                    _selectedWeekMax - _selectedWeek]);
                              });
                            },
                    ),
                  ],
                ),
              ],
            ),
            leading: Icon(Icons.more_time,
                color: Colors.green, size: iconSizeMedium),
            shape: shapePersoRoundedBorder(),
          ),

          /// Table
          Center(
            child: DataTable(
              /// Table header
              columns: [
                /// Revenues
                DataColumn(
                  label: InkWell(
                    // onTap: () {
                    //   _showChartDialog(context, 'Revenues', club.lisRevenues);
                    // },
                    child: buildTabWithIcon(
                        icon: Icons.trending_up, text: 'Revenues'),
                  ),
                ),

                /// Expenses
                DataColumn(
                  label: InkWell(
                    // onTap: () {
                    //   _showChartDialog(
                    //       context, 'Expenses', club.lisExpensesPlayers);
                    // },
                    child: buildTabWithIcon(
                        icon: Icons.trending_down, text: 'Expenses'),
                  ),
                ),
              ],
              rows: [
                /// 1st row
                DataRow(cells: [
                  /// Revenues Sponsors
                  DataCell(_getDataCellRow(
                      'Sponsors',
                      'Last Season: ${club.revenuesSponsorsLastSeason}',
                      _revenuesSponsors,
                      clubDataHistory.map((e) => e.revenuesSponsors).toList(),
                      Colors.green)),

                  /// Expenses Players
                  DataCell(_getDataCellRow(
                      'Salaries',
                      'Last week paied salary',
                      _expensesSalaries,
                      clubDataHistory.map((e) => e.expensesPlayers).toList(),
                      Colors.red)),
                ]),

                /// 2nd row
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow(
                      'Staff',
                      'Staff per week',
                      _expensesStaff,
                      clubDataHistory
                          .map((e) => e.expensesStaffApplied)
                          .toList(),
                      Colors.red)),
                ]),

                /// 3rd row
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow(
                      'Scouts',
                      'Scouts per week',
                      _expensesScouts,
                      clubDataHistory
                          .map((e) => e.expensesScoutsApplied)
                          .toList(),
                      Colors.red)),
                ]),

                /// 4th row
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow(
                      'Taxes',
                      '5% of the club' 's cash',
                      _expensesTaxes,
                      clubDataHistory.map((e) => e.expensesTax).toList(),
                      Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(_getDataCellRow(
                      'Transfers',
                      'Revenues from sold players',
                      _revenuesTransfersDone,
                      clubDataHistory
                          .map((e) => e.revenuesTransfersDone)
                          .toList(),
                      Colors.green)),
                  DataCell(_getDataCellRow(
                      'Transfers',
                      'Expenses from bought players',
                      _expensesTransfersDone,
                      clubDataHistory
                          .map((e) => e.expensesTransfersDone)
                          .toList(),
                      Colors.red)),
                ]),
                if (_selectedWeek == 0)
                  DataRow(cells: [
                    DataCell(_getDataCellRow(
                        '    (expected)',
                        'Expected revenues from selling players',
                        club.revenuesTransfersExpected,
                        clubDataHistory
                            .map((e) => e.revenuesTransfersDone)
                            .toList(),
                        Colors.green)),
                    DataCell(_getDataCellRow(
                        '    (expected)',
                        'Expected revenues from buying players',
                        club.expensesTransfersExpected,
                        clubDataHistory
                            .map((e) => e.expensesTransfersDone)
                            .toList(),
                        Colors.red)),
                  ]),

                /// Total
                DataRow(cells: [
                  DataCell(_getDataCellRow(
                      'Total',
                      'Weekly Revenues',
                      _revenuesTotal,
                      clubDataHistory.map((e) => e.revenuesTotal).toList(),
                      Colors.green)),
                  DataCell(_getDataCellRow(
                      'Total',
                      'Weekly expenses',
                      _expensesTotal,
                      clubDataHistory.map((e) => e.expensesTotal).toList(),
                      Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow(
                    'Total',
                    'Difference between revenues and expenses',
                    _weeklyTotal,
                    quiver
                        .zip([
                          clubDataHistory.map((e) => e.revenuesTotal),
                          clubDataHistory.map((e) => e.expensesTotal)
                        ])
                        .map((pair) => pair[0] - pair[1])
                        .toList(),
                    (_weeklyTotal ?? 0) < 0 ? Colors.red : Colors.green,
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDataCellRow(String title, String tooltipMessage, int? value,
      List<int> data, Color color) {
    return Tooltip(
      message: tooltipMessage,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                width: 120, child: Text(title, style: styleItalicBlueGrey)),
            Text(
              value == null ? '?' : persoFormatCurrency(value),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        onTap: () {
          _showChartDialog(context, title, data);
        },
      ),
    );
  }

  Widget _getFinancesHistory(Club club, List<ClubData> clubDataHistory) {
    List<FlSpot> cashData = [];
    List<FlSpot> revenuesData = [];
    List<FlSpot> expensesData = [];
    List<double> allValues = [];

    for (var i = 0; i < clubDataHistory.length; i++) {
      final clubData = clubDataHistory[i];
      final xValue = i.toDouble();

      if (_showCashCurve) {
        final yValue = clubData.cash.toDouble();
        cashData.add(FlSpot(xValue, yValue));
        allValues.add(yValue);
      }

      if (_showRevenuesCurve) {
        final yValue = clubData.revenuesTotal.toDouble();
        revenuesData.add(FlSpot(xValue, yValue));
        allValues.add(yValue);
      }

      if (_showExpensesCurve) {
        final yValue = clubData.expensesTotal.toDouble();
        expensesData.add(FlSpot(xValue, yValue));
        allValues.add(yValue);
      }
    }

    double minY = allValues.isNotEmpty ? allValues.reduce(min) : 0;
    minY = min(0, (minY / 1000).floorToDouble() * 1000);

    double maxY = allValues.isNotEmpty ? allValues.reduce(max) : 0;
    maxY = (maxY / 1000).ceilToDouble() * 1000;

    List<LineChartBarData> lineBarsData = [];
    if (_showCashCurve) {
      lineBarsData.add(LineChartBarData(
        spots: cashData,
        color: Colors.blue,
        aboveBarData: BarAreaData(
          show: true,
          color:
              Colors.red.withOpacity(0.3), // Background color for positive cash
          cutOffY: 0,
          applyCutOffY: true,
        ),
      ));
    }
    if (_showRevenuesCurve) {
      lineBarsData.add(LineChartBarData(
        spots: revenuesData,
        color: Colors.green,
      ));
    }
    if (_showExpensesCurve) {
      lineBarsData.add(LineChartBarData(
        spots: expensesData,
        color: Colors.red,
      ));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Text('Cash'),
                value: _showCashCurve,
                onChanged: (bool? value) {
                  setState(() {
                    _showCashCurve = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text('Revenues'),
                value: _showRevenuesCurve,
                onChanged: (bool? value) {
                  setState(() {
                    _showRevenuesCurve = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text('Expenses'),
                value: _showExpensesCurve,
                onChanged: (bool? value) {
                  setState(() {
                    _showExpensesCurve = value!;
                  });
                },
              ),
            ),
          ],
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              lineBarsData: lineBarsData,
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: Colors.black,
                    strokeWidth: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
