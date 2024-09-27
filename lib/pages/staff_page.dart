import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
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
                  ListTile(
                    leading: Icon(iconStaff, size: iconSizeMedium),
                    title: Row(
                      children: [
                        Text('Staff expanses: '),
                        Icon(
                          iconMoney,
                          size: iconSizeSmall,
                        ),
                        SizedBox(width: 3.0),
                        Text(
                          NumberFormat.decimalPattern()
                              .format(club.staffExpanses),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Staff expanses of the club per week for training players',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    onTap: () async {
                      final TextEditingController controller =
                          TextEditingController(
                              text: club.staffExpanses.toString());

                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Update Staff Expanses'),
                            content: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: "Enter new staff expanses"),
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
                                  int? newExpanses =
                                      int.tryParse(controller.text);
                                  if (newExpanses == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Input could not be parsed as an integer'),
                                      ),
                                    );
                                  } else if (newExpanses ==
                                      club.staffExpanses) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Staff expanses is already set at ${club.staffExpanses} per week'),
                                      ),
                                    );
                                  } else {
                                    try {
                                      var response = await supabase
                                          .from('clubs')
                                          .update({
                                        'staff_expanses': newExpanses
                                      }).eq('id', club.id);

                                      print(response);

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Successfully updated the staff expanses'),
                                        ),
                                      );
                                    } catch (error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(error.toString()),
                                        ),
                                      );
                                    }
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.thermostat, size: iconSizeMedium),
                    title: Row(
                      children: [
                        Text('Staff skill: '),
                        Text(
                          NumberFormat.decimalPattern()
                              .format(club.staffExpanses),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Staff weigth of the club for training players',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  SizedBox(height: 12),
                  _getStaffExpansesHistory(club),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _getStaffExpansesHistory(Club club) {
    List<FlSpot> data = club.lisStaffExpanses
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
        .toList();

    return Container(
      height: 400,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: data,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
