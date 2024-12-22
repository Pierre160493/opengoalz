import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/clubCashListTile.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';

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
  bool _showCashCurve = true;
  bool _showRevenuesCurve = true;
  bool _showExpensesCurve = true;

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
                  buildTabWithIcon(iconMoney, 'Finances'),
                  buildTabWithIcon(iconHistory, 'History'),
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

          /// Start table
          Text(
            'Last week revenues and expenses',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
          Center(
            child: DataTable(
              columns: [
                DataColumn(
                  label: InkWell(
                    onTap: () {
                      _showChartDialog(context, 'Revenues', club.lisRevenues);
                    },
                    child: buildTabWithIcon(Icons.trending_up, 'Revenues'),
                  ),
                ),
                DataColumn(
                  label: InkWell(
                    onTap: () {
                      _showChartDialog(
                          context, 'Expenses', club.lisExpensesPlayers);
                    },
                    child: buildTabWithIcon(Icons.trending_down, 'Expenses'),
                  ),
                ),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Tooltip(
                    message:
                        'Last Season: ${club.revenuesSponsorsLastSeason == null ? 'None' : club.revenuesSponsorsLastSeason}',
                    child: _getDataCellRow(
                        'Sponsors', club.lisRevenuesSponsors, Colors.green),
                  )),
                  DataCell(_getDataCellRow(
                      'Salaries', club.lisExpensesPlayers, Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow(
                      'Staff', club.lisExpensesStaff, Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(Text('')),
                  DataCell(_getDataCellRow(
                      'Taxes', club.lisExpensesTax, Colors.red)),
                ]),
                DataRow(cells: [
                  DataCell(
                      _getDataCellRow('Total', club.lisRevenues, Colors.green)),
                  DataCell(
                      _getDataCellRow('Total', club.lisExpenses, Colors.red)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDataCellRow(String title, List<int> data, Color color) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(width: 120, child: Text(title, style: styleItalicBlueGrey)),
          Text(
            NumberFormat.decimalPattern().format(data.last),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
      onTap: () {
        _showChartDialog(context, title, data);
      },
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
