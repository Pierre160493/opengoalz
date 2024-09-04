import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/player_card.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/countries_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

Widget playerListWidget(BuildContext context, Profile user) {
  // If user has no club, show the ListTile with possibility of creating a club
  if (user.players.isEmpty) {
    return ListTile(
      leading: const Icon(Icons.cancel, color: Colors.red),
      title: const Text('You dont have any players yet'),
      subtitle: const Text('Create a player to start his career !',
          style:
              TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic)),
      trailing: IconButton(
        tooltip: 'Get a player',
        icon: const Icon(
          Icons.add,
          color: Colors.green,
        ),
        onPressed: () {
          _showAssignPlayerDialog(context);
        },
      ),
    );
  }
  return Column(
    children: [
      const SizedBox(height: 12),
      Expanded(
        child: ListView.builder(
          itemCount: user.players.length,
          itemBuilder: (context, index) {
            final Player player = user.players[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayersPage(
                      inputCriteria: {
                        'Players': [player.id]
                      },
                    ),
                  ),
                );
              },
              child: PlayerCard(
                  player: player,
                  index: user.players.length == 1 ? 0 : index + 1,
                  isExpanded: user.players.length == 1 ? true : false),
            );
          },
        ),
      ),
    ],
  );
}

void _showAssignPlayerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AssignPlayerDialog();
    },
  );
}

class AssignPlayerDialog extends StatefulWidget {
  @override
  _AssignPlayerDialogState createState() => _AssignPlayerDialogState();
}

class _AssignPlayerDialogState extends State<AssignPlayerDialog> {
  Multiverse? selectedMultiverse;
  Country? selectedCountry;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  double selectedAge = 15.0;
  DateTime? dateBirth;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create a new player'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                selectedMultiverse = await Navigator.push<Multiverse>(
                  context,
                  MultiversePage.route(
                    1,
                    isReturningMultiverse: true,
                  ),
                );
                setState(() {
                  if (selectedMultiverse != null) {
                    dateBirth = DateTime.now().subtract(Duration(
                        days: (selectedAge * 14 * 7 / selectedMultiverse!.speed)
                            .round()));
                  } else {
                    dateBirth = null;
                  }
                });
              },
              child: selectedMultiverse == null
                  ? Row(
                      children: [
                        Icon(iconError, color: Colors.red),
                        formSpacer3,
                        Text('Select Multiverse'),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(iconSuccessfulOperation, color: Colors.green),
                        formSpacer3,
                        Text(
                            'Selected Multiverse: ${selectedMultiverse!.speed}'),
                      ],
                    ),
            ),
            ElevatedButton(
              onPressed: () async {
                selectedCountry = await Navigator.push<Country>(
                  context,
                  CountriesPage.route(),
                );
                setState(() {});
              },
              child: selectedCountry == null
                  ? Row(
                      children: [
                        Icon(iconError, color: Colors.red),
                        formSpacer3,
                        Text('Select Country'),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(iconSuccessfulOperation, color: Colors.green),
                        formSpacer3,
                        Text('Selected Country: ${selectedCountry!.name}'),
                      ],
                    ),
            ),
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                hintText: 'First name of the player',
              ),
            ),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                hintText: 'Last name of the player',
              ),
            ),
            formSpacer6,
            Text('Select Age:'),
            Slider(
              value: selectedAge,
              min: 15.0,
              max: 35.0,
              divisions: 200,
              label: selectedAge.toStringAsFixed(1),
              onChanged: (double value) {
                setState(() {
                  selectedAge = value;
                  if (selectedMultiverse != null) {
                    dateBirth = DateTime.now().subtract(Duration(
                        days: (selectedAge * 14 * 7 / selectedMultiverse!.speed)
                            .round()));
                  } else {
                    dateBirth = null;
                  }
                });
              },
            ),
            Text(
              'Selected Age: ${selectedAge.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            if (dateBirth != null)
              Text(
                'Birth Date: ${DateFormat('MMMM d, yyyy').format(dateBirth!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (selectedMultiverse == null) {
              context.showSnackBarError(
                  'No multiverse selected, player creation aborted');
              return;
            }
            if (selectedCountry == null) {
              context.showSnackBarError(
                  'No country selected, player creation aborted');
              return;
            }
            if (selectedCountry!.selectedContinent == null) {
              context.showSnackBarError(
                  'ERROR: No continent selected, player creation aborted');
              return;
            }
            if (selectedCountry!.selectedContinent == 'Others') {
              context.showSnackBarError(
                  'Cannot select country from continent "Others", player creation aborted');
              return;
            }
            if (dateBirth == null) {
              context.showSnackBarError(
                  'Cannot select date of birth, player creation aborted');
              return;
            }
            if (await context.showConfirmationDialog(
                    'Are you sure you want to create a player from ${selectedCountry!.name} ?') !=
                true) {
              context.showSnackBarError('Player creation aborted');
              return;
            }

            // Update the club in the database
            bool isOK =
                await operationInDB(context, 'INSERT', 'players', data: {
              'username': Provider.of<SessionProvider>(context, listen: false)
                  .user!
                  .username,
              'id_country': selectedCountry!.id,
              'id_multiverse': selectedMultiverse!.id,
              'first_name': firstNameController.text,
              'last_name': lastNameController.text,
              'date_birth': dateBirth!.toIso8601String(),
              'training_points': selectedAge * 2,
            });
            if (isOK) {
              context.showSnackBarSuccess(
                  'You now incarne a new player in ${selectedCountry!.name} in the continent: ${selectedCountry!.selectedContinent} !');
              Navigator.of(context).pop();
            }
          },
          child: Text('Create Player'),
        ),
      ],
    );
  }
}

// Future<void> _assignPlayer(BuildContext context) async {
//   // Ask the mutliverse speed to the user
//   context.showSnackBarSuccess(
//       'Please select the multiverse in which you want the player to play');

//   /// Multiverse selection
//   Multiverse? selectedMultiverse = await Navigator.push<Multiverse>(
//     context,
//     MultiversePage.route(
//       1,
//       isReturningMultiverse: true,
//     ),
//   );
//   // Check selection and ask confirmation
//   if (selectedMultiverse == null) {
//     context
//         .showSnackBarError('No multiverse selected, player creation aborted');
//     return;
//   }

//   /// Country selection
//   Country? selectedCountry = await Navigator.push<Country>(
//     context,
//     CountriesPage.route(),
//   );
//   // Check selection and ask confirmation
//   if (selectedCountry == null) {
//     context.showSnackBarError('No country selected, player creation aborted');
//     return;
//   } else {
//     if (selectedCountry.selectedContinent == null) {
//       context.showSnackBarError(
//           'ERROR: No continent selected, player creation aborted');
//       return;
//     } else if (selectedCountry.selectedContinent == 'Others') {
//       context.showSnackBarError(
//           'Cannot select country from continent "Others", player creation aborted');
//       return;
//     } else {
//       if (await context.showConfirmationDialog(
//               'Are you sure you want to create a player from ${selectedCountry.name} ?') !=
//           true) {
//         context.showSnackBarError('Player creation aborted');
//         return;
//       }
//     }
//   }

//   // // Update the club in the database
//   bool isOK = await operationInDB(context, 'INSERT', 'players', data: {
//     'username':
//         Provider.of<SessionProvider>(context, listen: false).user!.username,
//     'id_country': selectedCountry.id,
//   });
//   if (isOK) {
//     context.showSnackBarSuccess(
//         'You are now the happy owner of a new club in ${selectedCountry.name} in the continent: ${selectedCountry.selectedContinent} !');
//   }
// }
