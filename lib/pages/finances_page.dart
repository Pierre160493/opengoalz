import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/clubCashListTile.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'package:quiver/iterables.dart' as quiver;

class FinancesPage extends StatefulWidget {
  final int idClub;
  const FinancesPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => FinancesPage(idClub: idClub),
    );
  }

  @override
  State<FinancesPage> createState() => _FinancesPageState();
}

class _FinancesPageState extends State<FinancesPage> {
  // late final Stream<List<Map<String, dynamic>>> _financeStream;
  late Club _club;
  bool _showCashCurve = true;
  bool _showRevenuesCurve = true;
  bool _showExpensesCurve = true;
  late int _selectedWeek;
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
  List<int> _lisWeeklyTotal = [];

  @override
  void initState() {
    // _financeStream = supabase
    //     .from('finances')
    //     .stream(primaryKey: ['id'])
    //     .eq('id_club', widget.idClub)
    //     .order('created_at')
    //     .map((maps) => maps
    //         .map((map) => {
    //               'id': map['id'],
    //               'created_at': map['created_at'],
    //               'amount': map['amount'],
    //               'description': map['description'],
    //             })
    //         .toList());

    _club = Provider.of<SessionProvider>(context, listen: false)
        .user!
        .selectedClub!;

    _selectedWeek = 0;

    _calculateValues();

    _lisWeeklyTotal = quiver
        .zip([_club.lisRevenues, _club.lisExpenses])
        .map((pair) => pair[0] - pair[1])
        .toList();

    super.initState();
  }

  void _showChartDialog(BuildContext context, String title, List<num> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final chartData = ChartData(
          title: title,
          yValues: data,
        );

        return PlayerLineChartDialogBox(chartData: chartData);
      },
    );
  }

  void _calculateValues() {
    if (_selectedWeek == 0) {
      _revenuesSponsors = _club.revenuesSponsors;
      _expensesSalaries = _club.expensesPlayers;
      _expensesStaff = _club.expensesStaffTarget;
      _expensesScouts = _club.expensesScoutsTarget;
      _expensesTaxes = (_club.cash * 0.05).floor();
      _revenuesTransfersDone = _club.revenuesTransfersDone;
      _expensesTransfersDone = _club.expensesTransfersDone;
      _revenuesTotal = _revenuesSponsors! + _revenuesTransfersDone!;
      _expensesTotal = _expensesSalaries! +
          _expensesStaff! +
          _expensesScouts! +
          _expensesTaxes! +
          _expensesTransfersDone!;
    } else {
      /// Sponsors
      _revenuesSponsors =
          _getValueFromList(_club.lisRevenuesSponsors, _selectedWeek);

      /// Salaries
      _expensesSalaries =
          _getValueFromList(_club.lisExpensesPlayers, _selectedWeek);

      /// Staff
      _expensesStaff = _getValueFromList(_club.lisExpensesStaff, _selectedWeek);

      /// Scouts
      _expensesScouts =
          _getValueFromList(_club.lisExpensesScouts, _selectedWeek);

      /// Taxes
      _expensesTaxes = _getValueFromList(_club.lisExpensesTax, _selectedWeek);

      /// Transfers
      _revenuesTransfersDone =
          _getValueFromList(_club.lisRevenuesTransfers, _selectedWeek);

      _expensesTransfersDone =
          _getValueFromList(_club.lisExpensesTransfers, _selectedWeek);

      /// Total
      _revenuesTotal = _getValueFromList(_club.lisRevenues, _selectedWeek);

      _expensesTotal = _getValueFromList(_club.lisExpenses, _selectedWeek);
    }

    try {
      _weeklyTotal = _revenuesTotal! - _expensesTotal!;
    } catch (e) {
      _weeklyTotal = null;
    }
  }

  int? _getValueFromList(List<int> list, int selectedWeek) {
    int length = list.length;
    return length >= selectedWeek ? list[length - selectedWeek] : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finances'),
      ),
      drawer: const AppDrawer(),
      body: MaxWidthContainer(
        child: DefaultTabController(
          length: 2, // The number of tabs
          child: Column(
            children: [
              TabBar(
                tabs: [
                  buildTabWithIcon(icon: iconMoney, text: 'Finances'),
                  buildTabWithIcon(icon: iconHistory, text: 'History'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _getFinances(
                        Provider.of<SessionProvider>(context, listen: false)
                            .user!
                            .selectedClub!),
                    _getFinancesHistory(
                        Provider.of<SessionProvider>(context, listen: false)
                            .user!
                            .selectedClub!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getFinances(Club club) {
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
                      onPressed: () {
                        setState(() {
                          _selectedWeek = _selectedWeek + 7;
                          _calculateValues();
                        });
                      },
                    ),
                    IconButton(
                      tooltip: 'Previous week',
                      icon: Icon(Icons.keyboard_arrow_left),
                      onPressed: () {
                        setState(() {
                          _selectedWeek = _selectedWeek + 1;
                          _calculateValues();
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
                                _calculateValues();
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
                                _calculateValues();
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
                    onTap: () {
                      _showChartDialog(context, 'Revenues', club.lisRevenues);
                    },
                    child: buildTabWithIcon(
                        icon: Icons.trending_up, text: 'Revenues'),
                  ),
                ),

                /// Expenses
                DataColumn(
                  label: InkWell(
                    onTap: () {
                      _showChartDialog(
                          context, 'Expenses', club.lisExpensesPlayers);
                    },
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
                      'Last Season: ${club.revenuesSponsorsLastSeason == null ? 'None' : club.revenuesSponsorsLastSeason}',
                      _revenuesSponsors,
                      club.lisRevenuesSponsors,
                      Colors.green)),

                  /// Expenses Players
                  DataCell(_getDataCellRow('Salaries', 'Last week paied salary',
                      _expensesSalaries, club.lisExpensesPlayers, Colors.red)),
                ]),

                /// 2nd row
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow('Staff', 'Staff per week',
                      _expensesStaff, club.lisExpensesStaff, Colors.red)),
                ]),

                /// 3rd row
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow('Scouts', 'Scouts per week',
                      _expensesScouts, club.lisExpensesStaff, Colors.red)),
                ]),

                /// 4th row
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow('Taxes', '5% of the club' 's cash',
                      _expensesTaxes, club.lisExpensesTax, Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(_getDataCellRow(
                      'Transfers',
                      'Revenues from sold players',
                      _revenuesTransfersDone,
                      club.lisRevenuesTransfers,
                      Colors.green)),
                  DataCell(_getDataCellRow(
                      'Transfers',
                      'Expenses from bought players',
                      _expensesTransfersDone,
                      club.lisExpensesTransfers,
                      Colors.red)),
                ]),
                if (_selectedWeek == 0)
                  DataRow(cells: [
                    DataCell(_getDataCellRow(
                        '    (expected)',
                        'Expected revenues from selling players',
                        club.revenuesTransfersExpected,
                        club.lisRevenuesTransfers,
                        Colors.green)),
                    DataCell(_getDataCellRow(
                        '    (expected)',
                        'Expected revenues from buying players',
                        club.expensesTransfersExpected,
                        club.lisExpensesTransfers,
                        Colors.red)),
                  ]),

                /// Total
                DataRow(cells: [
                  DataCell(_getDataCellRow('Total', 'Weekly Revenues',
                      _revenuesTotal, club.lisRevenues, Colors.green)),
                  DataCell(_getDataCellRow('Total', 'Weekly expenses',
                      _expensesTotal, club.lisExpenses, Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow(
                    'Total',
                    'Difference between revenues and expenses',
                    _weeklyTotal,
                    _lisWeeklyTotal,
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

  Widget _getFinancesHistory(Club club) {
    List<FlSpot> cashData = club.lisCash
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();

    List<FlSpot> revenuesData = club.lisRevenues
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();

    List<FlSpot> expensesData = club.lisExpenses
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();

    List<double> allValues = [];
    if (_showCashCurve) {
      allValues.addAll(club.lisCash.map((e) => e.toDouble()));
    }
    if (_showRevenuesCurve) {
      allValues.addAll(club.lisRevenues.map((e) => e.toDouble()));
    }
    if (_showExpensesCurve) {
      allValues.addAll(club.lisExpenses.map((e) => e.toDouble()));
    }

    double minY = allValues.isNotEmpty ? allValues.reduce(min) : 0;
    minY = (minY / 1000).floorToDouble() * 1000;

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
