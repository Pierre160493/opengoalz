import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/stringValueSeparated.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/clubCashListTile.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/financesGraphDialogBox.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';

class StaffPage extends StatefulWidget {
  final int idClub;
  const StaffPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => StaffPage(idClub: idClub),
    );
  }

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  late final Stream<Club> _clubStream;

  @override
  void initState() {
    _clubStream = supabase

        /// Fetch the club
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => maps.map((map) => Club.fromMap(map)).first);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Club>(
      stream: _clubStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error occurred: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          Club club = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Staff of ${club.name}'),
            ),
            drawer: const AppDrawer(),
            body: MaxWidthContainer(
              child: Column(
                children: [
                  /// Club cash
                  getClubCashListTile(context, club),

                  /// Staff expenses
                  ListTile(
                    leading: Icon(iconStaff,
                        size: iconSizeMedium, color: Colors.green),
                    title: Row(
                      children: [
                        Text('Staff expenses: '),
                        Icon(
                          iconMoney,
                          size: iconSizeSmall,
                        ),
                        SizedBox(width: 3.0),
                        Text(
                          stringValueSeparated(club.expensesStaffTarget),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Theoretical Expenses dedicated for staff per week',
                      style: styleItalicBlueGrey,
                    ),
                    shape: shapePersoRoundedBorder(),
                    trailing: IconButton(
                        onPressed: () async {
                          final TextEditingController controller =
                              TextEditingController(
                                  text: club.expensesStaffTarget.toString());

                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Update Staff Expenses'),
                                content: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: "Enter new staff expenses"),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Update'),
                                    onPressed: () async {
                                      int? newExpenses =
                                          int.tryParse(controller.text);
                                      if (newExpenses == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Input could not be parsed as an integer'),
                                          ),
                                        );
                                      } else if (newExpenses ==
                                          club.expensesStaffTarget) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Staff expenses is already set at ${club.expensesStaffTarget} per week'),
                                          ),
                                        );
                                      } else {
                                        bool isOK = await operationInDB(
                                            context, 'UPDATE', 'clubs', data: {
                                          'expenses_staff_target': newExpenses
                                        }, matchCriteria: {
                                          'id': club.id
                                        });

                                        if (isOK) {
                                          context.showSnackBarSuccess(
                                              'Successfully updated the staff expenses target to $newExpenses per week');
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        }
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(Icons.currency_exchange,
                            color: Colors.orange)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return FinancesGraphDialog(
                          //   nameCurves: 'Staff Expenses',
                          //   dataPoints: club.lisExpensesStaff,
                          // );

                          final chartData = ChartData(
                            title: 'Staff Expenses History (per weeks)',
                            yValues: [
                              club.lisExpensesStaff
                                  .map((e) => e.toDouble())
                                  .toList()
                            ],
                            typeXAxis: XAxisType.weekHistory,
                          );

                          return ChartDialogBox(chartData: chartData);
                        },
                      );
                    },
                  ),

                  /// Staff weight
                  ListTile(
                    leading: Icon(Icons.thermostat,
                        size: iconSizeMedium, color: Colors.green),
                    title: Row(
                      children: [
                        Text('Staff skill: '),
                        Text(
                          stringValueSeparated(club.staffWeight.round()),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Staff skill for training players',
                      style: styleItalicBlueGrey,
                    ),
                    shape: shapePersoRoundedBorder(),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final chartData = ChartData(
                            title: 'Staff Skill History (per weeks)',
                            yValues: [
                              club.lisStaffWeight
                                  .map((e) => e.toDouble())
                                  .toList()
                            ],
                            typeXAxis: XAxisType.weekHistory,
                          );

                          return ChartDialogBox(chartData: chartData);
                        },
                      );
                    },
                  ),
                  // SizedBox(height: 12),
                  // _getStaffExpensesHistory(club),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // Widget _getStaffExpensesHistory(Club club) {
  //   List<FlSpot> data = club.lisStaffExpenses
  //       .asMap()
  //       .entries
  //       .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
  //       .toList();

  //   return Container(
  //     height: 400,
  //     child: LineChart(
  //       LineChartData(
  //         lineBarsData: [
  //           LineChartBarData(
  //             spots: data,
  //             color: Colors.blue,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
