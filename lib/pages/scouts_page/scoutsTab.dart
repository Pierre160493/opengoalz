import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/stringFunctions.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club_data.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/scoutsDialogBox.dart';
import 'package:provider/provider.dart';

class ScoutsMainTab extends StatelessWidget {
  final Club club;
  final int _costForNewPlayer = 7000;

  ScoutsMainTab(this.club);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(iconScouts, size: iconSizeMedium, color: Colors.green),
          title: Row(
            children: [
              Text('Scouting Network expenses: '),
              Icon(
                iconMoney,
                size: iconSizeSmall,
              ),
              SizedBox(width: 3.0),
              Text(
                stringValueSeparated(club.clubData.expensesScoutsTarget),
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
                final TextEditingController controller = TextEditingController(
                    text: club.clubData.expensesScoutsTarget.toString());

                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Update Scouting Network Expenses'),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: "Enter new scouting network expenses"),
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
                            int? newExpenses = int.tryParse(controller.text);
                            if (newExpenses == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Input could not be parsed as an integer'),
                                ),
                              );
                            } else if (newExpenses ==
                                club.clubData.expensesScoutsTarget) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Scouting Network expenses is already set at ${club.clubData.expensesScoutsTarget} per week'),
                                ),
                              );
                            } else {
                              bool isOK = await operationInDB(
                                  context, 'UPDATE', 'clubs',
                                  data: {'expenses_scouts_target': newExpenses},
                                  matchCriteria: {'id': club.id});

                              if (isOK) {
                                context.showSnackBarSuccess(
                                    'Successfully updated the scouting network expenses target to $newExpenses per week');
                                Navigator.of(context).pop(); // Close the dialog
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.currency_exchange, color: Colors.orange)),
          onTap: () async {
            ClubData.showClubHistoryChartDialog(
              context,
              club.id,
              'expenses_scouts_applied',
              'Scouting Network Expenses',
            );
          },
        ),

        /// Scouting Network weight
        ListTile(
          leading:
              Icon(Icons.thermostat, size: iconSizeMedium, color: Colors.green),
          title: Row(
            children: [
              Text('Scouting Network Strength: '),
              Text(
                stringValueSeparated(club.clubData.scoutsWeight.round()),
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
              club.id,
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
    );
  }
}
