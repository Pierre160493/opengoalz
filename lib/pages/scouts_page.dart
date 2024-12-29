import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/stringValueSeparated.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/clubCashListTile.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';

class ScoutsPage extends StatefulWidget {
  final int idClub;
  const ScoutsPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => ScoutsPage(idClub: idClub),
    );
  }

  @override
  State<ScoutsPage> createState() => _ScoutsPageState();
}

class _ScoutsPageState extends State<ScoutsPage> {
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
              title: Text('Scouting Network'),
            ),
            drawer: const AppDrawer(),
            body: MaxWidthContainer(
              child: Column(
                children: [
                  /// Club cash
                  getClubCashListTile(context, club),

                  /// Scouting Network expenses
                  ListTile(
                    leading: Icon(iconScouts,
                        size: iconSizeMedium, color: Colors.green),
                    title: Row(
                      children: [
                        Text('Scouting Network expenses: '),
                        Icon(
                          iconMoney,
                          size: iconSizeSmall,
                        ),
                        SizedBox(width: 3.0),
                        Text(
                          stringValueSeparated(club.expensesScoutsTarget),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Theoretical Expenses dedicated for scouting network per week',
                      style: styleItalicBlueGrey,
                    ),
                    shape: shapePersoRoundedBorder(),
                    trailing: IconButton(
                        onPressed: () async {
                          final TextEditingController controller =
                              TextEditingController(
                                  text: club.expensesScoutsTarget.toString());

                          await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Update Scouting Network Expenses'),
                                content: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText:
                                          "Enter new scouting network expenses"),
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
                                          club.expensesScoutsTarget) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Scouting Network expenses is already set at ${club.expensesScoutsTarget} per week'),
                                          ),
                                        );
                                      } else {
                                        bool isOK = await operationInDB(
                                            context, 'UPDATE', 'clubs', data: {
                                          'expenses_scouts_target': newExpenses
                                        }, matchCriteria: {
                                          'id': club.id
                                        });

                                        if (isOK) {
                                          context.showSnackBarSuccess(
                                              'Successfully updated the scouting network expenses target to $newExpenses per week');
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
                          final chartData = ChartData(
                            title:
                                'Scouting Network Expenses History (per weeks)',
                            yValues: club.lisExpensesScouts
                                .map((e) => e.toDouble())
                                .toList(),
                          );

                          return PlayerLineChartDialogBox(chartData: chartData);
                        },
                      );
                    },
                  ),

                  /// Scouting Network weight
                  ListTile(
                    leading: Icon(Icons.thermostat,
                        size: iconSizeMedium, color: Colors.green),
                    title: Row(
                      children: [
                        Text('Scouting Network Skill: '),
                        Text(
                          stringValueSeparated(club.scoutsWeight.round()),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Scouts skill for searching players',
                      style: styleItalicBlueGrey,
                    ),
                    shape: shapePersoRoundedBorder(),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final chartData = ChartData(
                            title: 'Scouting Network Skill History (per weeks)',
                            yValues: club.lisScoutsWeight
                                .map((e) => e.toDouble())
                                .toList(),
                          );

                          return PlayerLineChartDialogBox(chartData: chartData);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
