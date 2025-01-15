import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/stringFunctions.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/graphWidget.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/scoutsDialogBox.dart';
import 'package:provider/provider.dart';

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
  int _costForNewPlayer = 7000;

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
              actions: [
                Tooltip(
                  message: 'Help',
                  child: IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.green),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Scouting System Help'),
                            content: Text(
                              'The scouting system allows you to manage and track the expenses and skills of your scouting network.\n\n'
                              'Every week, you can invest a sum of money into the scouting network to build up its strength.\n\n'
                              'The expenses dedicated to scouting are theoretical and represent the amount you plan to spend each week, if your finances permit it !\n\n'
                              'As you continue to invest, the scouting network strength will increase.\n\n'
                              'Once the scouting strength reaches ${_costForNewPlayer}, you can call the scouts to find a new player.\n\n'
                              'You can also view the historical data of scouting expenses and the strength of your scouting network over time.',
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            drawer: const AppDrawer(),
            body: MaxWidthContainer(
              child: Column(
                children: [
                  /// Club cash
                  // getClubCashListTile(context, club),

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
                          stringValueSeparated(
                              club.clubData.expensesScoutsTarget),
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
                                  text: club.clubData.expensesScoutsTarget
                                      .toString());

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
                                          club.clubData.expensesScoutsTarget) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Scouting Network expenses is already set at ${club.clubData.expensesScoutsTarget} per week'),
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
                    onTap: () async {
                      ClubData.showClubHistoryChartDialog(
                        context,
                        club,
                        'expenses_scouts_applied',
                        'Scouting Network Expenses',
                      );
                    },
                  ),

                  /// Scouting Network weight
                  ListTile(
                    leading: Icon(Icons.thermostat,
                        size: iconSizeMedium, color: Colors.green),
                    title: Row(
                      children: [
                        Text('Scouting Network Strength: '),
                        Text(
                          stringValueSeparated(
                              club.clubData.scoutsWeight.round()),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: const Text(
                      'Strength of the scouting network for searching young players',
                      style: styleItalicBlueGrey,
                    ),
                    shape: shapePersoRoundedBorder(),
                    onTap: () async {
                      ClubData.showClubHistoryChartDialog(
                        context,
                        club,
                        'scouts_weight',
                        'Scouting Network Strength',
                      );
                    },
                  ),

                  /// Fetch a new player
                  if (club.id ==
                      Provider.of<SessionProvider>(context, listen: false)
                          .user!
                          .selectedClub!
                          .id)
                    ListTile(
                      leading: Icon(Icons.phone,
                          size: iconSizeMedium,
                          color: club.clubData.scoutsWeight < _costForNewPlayer
                              ? Colors.orange
                              : Colors.green),
                      title: Text('Call the scouts !'),
                      subtitle: Text(
                        'Spend ${_costForNewPlayer.toString()} scouting strength to find a new player',
                        style: styleItalicBlueGrey,
                      ),
                      shape: shapePersoRoundedBorder(
                          club.clubData.scoutsWeight < _costForNewPlayer
                              ? Colors.red
                              : Colors.green),
                      onTap: club.clubData.scoutsWeight < _costForNewPlayer
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ScoutsDialog(club: club);
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
