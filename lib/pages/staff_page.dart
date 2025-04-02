import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/functions/stringFunctions.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
import 'package:opengoalz/models/club/clubCashListTile.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:opengoalz/widgets/staff_detail_tab.dart';

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
    final Profile user =
        Provider.of<UserSessionProvider>(context, listen: false).user;

    _clubStream = supabase

        /// Fetch the club
        .from('clubs')
        .stream(primaryKey: ['id'])
        .eq('id', widget.idClub)
        .map((maps) => maps.map((map) => Club.fromMap(map)).first)
        .switchMap((Club club) {
          List<int> idPlayerStaff = [club.idScout, club.idCoach]
              .where((id) => id != null)
              .cast<int>()
              .toList();
          if (idPlayerStaff.isEmpty) {
            return Stream.value(club);
          }
          // Fetch the club's players
          return supabase
              .from('players')
              .stream(primaryKey: ['id'])
              .inFilter('id',
                  idPlayerStaff) // Fetch the club's players to get their clubs
              .map((maps) =>
                  maps.map((map) => Player.fromMap(map, user)).toList())
              .map((List<Player> playersStaff) {
                for (Player player in playersStaff) {
                  if (player.id == club.idCoach) {
                    club.coach = player;
                  } else if (player.id == club.idScout) {
                    club.scout = player;
                  }
                }
                return club;
              });
        });

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
          return loadingCircularAndText('Loading club...');
        } else {
          Club club = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text('Staff of '),
                  club.getClubNameClickable(context),
                ],
              ),
              leading: goBackIconButton(context),
            ),
            body: MaxWidthContainer(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        buildTabWithIcon(
                            icon: Icons.remove_red_eye, text: 'Overview'),
                        buildTabWithIcon(
                            icon: iconCoach,
                            text: 'Coach',
                            iconColor:
                                club.coach == null ? Colors.red : Colors.green),
                        buildTabWithIcon(
                            icon: iconScout,
                            text: 'Scout',
                            iconColor:
                                club.scout == null ? Colors.red : Colors.green),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          StaffOverviewTab(club: club),
                          StaffDetailTab(club: club, title: 'Coach'),
                          StaffDetailTab(club: club, title: 'Scout'),
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
}

class StaffOverviewTab extends StatelessWidget {
  final Club club;

  const StaffOverviewTab({Key? key, required this.club}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Club cash
        getClubCashListTile(context, club),
        // Staff expenses
        ListTile(
          leading: Icon(iconStaff, size: iconSizeMedium, color: Colors.green),
          title: Column(
            children: [
              Row(
                children: [
                  Text('Staff expenses '),
                  Icon(iconMoney, size: iconSizeSmall, color: Colors.green),
                  SizedBox(width: 3.0),
                  Text(
                    stringValueSeparated(club.clubData.expensesTrainingTarget +
                        club.clubData.expensesScoutsTarget),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              formSpacer3,

              /// Training expenses
              ListTile(
                leading:
                    Icon(iconCoach, size: iconSizeSmall, color: Colors.green),
                title: Text(
                  stringValueSeparated(club.clubData.expensesTrainingTarget),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Training expenses per week',
                  style: styleItalicBlueGrey,
                ),
                shape: shapePersoRoundedBorder(),
                trailing: IconButton(
                  tooltip: 'Update training weekly expenses',
                  onPressed: () async {
                    final TextEditingController controller =
                        TextEditingController(
                            text: club.clubData.expensesTrainingTarget
                                .toString());
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(iconCoach, color: Colors.green),
                              Text('Update training Weekly Expenses'),
                            ],
                          ),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "Enter new training weekly expenses"),
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: persoCancelRow,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: persoValidRow('Update'),
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
                                        club.clubData.expensesTrainingTarget) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Training expenses is already set at ${club.clubData.expensesTrainingTarget} per week'),
                                        ),
                                      );
                                    } else {
                                      bool isOK = await operationInDB(
                                          context, 'UPDATE', 'clubs', data: {
                                        'expenses_training_target': newExpenses
                                      }, matchCriteria: {
                                        'id': club.id
                                      });
                                      if (isOK) {
                                        context.showSnackBarSuccess(
                                            'Successfully updated the training weekly expenses target to $newExpenses per week');
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.currency_exchange, color: Colors.orange),
                ),
                onTap: () async {
                  ClubData.showClubHistoryChartDialog(
                    context,
                    club.id,
                    'expenses_training_applied',
                    'Weekly Training Expenses',
                  );
                },
              ),

              /// Scouts expenses
              ListTile(
                leading:
                    Icon(iconScout, size: iconSizeSmall, color: Colors.green),
                title: Text(
                  stringValueSeparated(club.clubData.expensesScoutsTarget),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Theoretical scouts weekly expenses',
                  style: styleItalicBlueGrey,
                ),
                shape: shapePersoRoundedBorder(),
                trailing: IconButton(
                  tooltip: 'Update scouts weekly expenses',
                  onPressed: () async {
                    final TextEditingController controller =
                        TextEditingController(
                            text:
                                club.clubData.expensesScoutsTarget.toString());
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(iconScout, color: Colors.green),
                              Text('Update Scouts Weekly Expenses'),
                            ],
                          ),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "Enter new scouts weekly expenses"),
                          ),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: persoCancelRow,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: persoValidRow('Update'),
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
                                              'Scouts expenses is already set at ${club.clubData.expensesScoutsTarget} per week'),
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
                                            'Successfully updated the scouts weekly expenses target to $newExpenses per week');
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.currency_exchange, color: Colors.orange),
                ),
                onTap: () async {
                  ClubData.showClubHistoryChartDialog(
                    context,
                    club.id,
                    'expenses_scouts_applied',
                    'Weekly Scouts Expenses',
                  );
                },
              ),
            ],
          ),
          subtitle: const Text(
            'Theoretical Expenses dedicated for staff per week',
            style: styleItalicBlueGrey,
          ),
          shape: shapePersoRoundedBorder(),
        ),

        /// Training weight
        ListTile(
          leading:
              Icon(Icons.thermostat, size: iconSizeMedium, color: Colors.green),
          title: Row(
            children: [
              Text('Club\'s Training skill '),
              Text(
                stringValueSeparated(club.clubData.staffWeight.round()),
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          subtitle: const Text(
            'Club\'s training skill for training players',
            style: styleItalicBlueGrey,
          ),
          shape: shapePersoRoundedBorder(),
          onTap: () async {
            ClubData.showClubHistoryChartDialog(
              context,
              club.id,
              'training_weight',
              'Weekly Staff Weight',
            );
          },
        ),
      ],
    );
  }
}
