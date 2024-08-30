import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
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
  late final Stream<List<Map<String, dynamic>>> _financeStream;

  @override
  void initState() {
    _financeStream = supabase
        .from('finances')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .order('created_at')
        .map((maps) => maps
            .map((map) => {
                  'id': map['id'],
                  'created_at': map['created_at'],
                  'amount': map['amount'],
                  'description': map['description'],
                })
            .toList());

    super.initState();
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
                    _getFinances(Provider.of<SessionProvider>(context)
                        .user!
                        .selectedClub!),
                    _getFinancesHistory(Provider.of<SessionProvider>(context)
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
      child: Center(
        child: DataTable(
          columns: [
            DataColumn(
              label: buildTabWithIcon(Icons.trending_up, 'Revenues'),
            ),
            DataColumn(
                label: buildTabWithIcon(Icons.trending_down, 'Expanses')),
          ],
          rows: [
            DataRow(cells: [
              DataCell(_getDataCellRow(
                  'Sponsors', club.lisSponsors.last, Colors.green)),
              DataCell(_getDataCellRow(
                  'Salaries', club.lisPlayersExpanses.last, Colors.red)),
            ]),
            DataRow(cells: [
              DataCell(Text('')),
              DataCell(_getDataCellRow(
                  'Staff', club.lisStaffExpanses.last, Colors.red)),
            ]),
            DataRow(cells: [
              DataCell(Text('')),
              DataCell(_getDataCellRow('Taxes', club.lisTax.last, Colors.red)),
            ]),
            DataRow(cells: [
              DataCell(_getDataCellRow(
                  'Total', club.lisRevenues.last, Colors.green)),
              DataCell(
                  _getDataCellRow('Total', club.lisExpanses.last, Colors.red)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _getDataCellRow(String title, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${title}:    '),
        Text(
          NumberFormat.decimalPattern().format(value),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
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

    List<FlSpot> expansesData = club.lisExpanses
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();

    double minY = [
      club.lisCash.reduce(min),
      club.lisRevenues.reduce(min),
      club.lisExpanses.reduce(min),
    ].reduce(min).toDouble();
    minY = (minY / 1000).floorToDouble() * 1000;

    double maxY = [
      club.lisCash.reduce(max),
      club.lisRevenues.reduce(max),
      club.lisExpanses.reduce(max),
    ].reduce(max).toDouble();
    maxY = (maxY / 1000).ceilToDouble() * 1000;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: cashData,
            color: Colors.blue,
          ),
          LineChartBarData(
            spots: revenuesData,
            color: Colors.green,
          ),
          LineChartBarData(
            spots: expansesData,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
