import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/club/clubCardWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/player_card.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/clubAndPlayerCreationDialogBox.dart';

Widget clubListWidget(BuildContext context, Profile user) {
  return Column(
    children: [
      formSpacer6,
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.list, color: Colors.green),
          SizedBox(width: 8),
          Text(
            'Here is the list of your clubs:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      formSpacer6,
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: user.clubs.length,
          itemBuilder: (context, index) {
            final Club club = user.clubs[index];
            return getClubCard(context, club, index);
          },
        ),
      ),
      if (user.numberClubsAvailable > user.clubs.length)
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24), // Adjust border radius as needed
            side: const BorderSide(
              color: Colors.blueGrey, // Border color
            ),
          ),
          leading: const Icon(Icons.add_home_work, color: Colors.green),
          title: Text(user.clubs.length == 0
              ? 'You dont have any club yet'
              : 'Get an additional club'),
          subtitle: Text(
              user.clubs.length == 0
                  ? 'Create a club to start your aventure and show your skills !'
                  : 'Get an additional club to show your skills',
              style: TextStyle(
                  color: Colors.blueGrey, fontStyle: FontStyle.italic)),
          onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AssignPlayerOrClubDialog(isClub: true);
            },
          ),
        ),
    ],
  );
}

Widget playerListWidget(BuildContext context, Profile user) {
  // If user has no club, show the ListTile with possibility of creating a club

  return Column(
    children: [
      const SizedBox(height: 12),
      Flexible(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: user.players.length,
          itemBuilder: (context, index) {
            final Player player = user.players[index];
            return InkWell(
              onTap: () {
                print('Player tapped');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayersPage(
                      playerSearchCriterias:
                          PlayerSearchCriterias(idPlayer: [player.id]),
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
      if (user.numberPlayersAvailable > user.players.length)
        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24), // Adjust border radius as needed
            side: const BorderSide(
              color: Colors.blueGrey, // Border color
            ),
          ),
          leading: Icon(
              user.players.length > 1
                  ? Icons.person_add_alt_1
                  : Icons.group_add,
              color: Colors.green),
          title: Text(user.players.length == 0
              ? 'You dont have any players yet'
              : 'Get an additional player'),
          subtitle: const Text('Create a player and start his amazing career !',
              style: TextStyle(
                  color: Colors.blueGrey, fontStyle: FontStyle.italic)),
          onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return AssignPlayerOrClubDialog(isClub: false);
            },
          ),
        ),
    ],
  );
}

// class AssignPlayerOrClubDialog extends StatefulWidget {
//   final isClub; // Should the assignement be for a club or a player
//   AssignPlayerOrClubDialog({required this.isClub});
//   @override
//   _AssignPlayerOrClubDialogState createState() =>
//       _AssignPlayerOrClubDialogState();
// }

// class _AssignPlayerOrClubDialogState extends State<AssignPlayerOrClubDialog> {
//   Multiverse? selectedMultiverse;
//   Country? selectedCountry;
//   Club? selectedClub;
//   final TextEditingController clubNameController = TextEditingController();
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   double selectedAge = 15.0;
//   DateTime? dateBirth;

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title:
//           widget.isClub ? Text('Get a new club') : Text('Create a new player'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             /// Select the multiverse
//             ElevatedButton(
//               onPressed: () async {
//                 selectedMultiverse = await Navigator.push<Multiverse>(
//                   context,
//                   MultiversePage.route(
//                     1,
//                     isReturningMultiverse: true,
//                   ),
//                 );
//                 setState(() {
//                   if (selectedMultiverse != null) {
//                     dateBirth = DateTime.now().subtract(Duration(
//                         days: (selectedAge * 14 * 7 / selectedMultiverse!.speed)
//                             .round()));
//                   } else {
//                     dateBirth = null;
//                   }
//                 });
//               },
//               child: selectedMultiverse == null
//                   ? Row(
//                       children: [
//                         Icon(iconError, color: Colors.red),
//                         formSpacer3,
//                         Text('Select Multiverse'),
//                       ],
//                     )
//                   : Row(
//                       children: [
//                         Icon(iconSuccessfulOperation, color: Colors.green),
//                         formSpacer3,
//                         Text(
//                             'Selected Multiverse: ${selectedMultiverse!.name}'),
//                       ],
//                     ),
//             ),
//             getMultiverseSelectionListTile(context, selectedMultiverse),

//             /// Select the country
//             ElevatedButton(
//               onPressed: () async {
//                 selectedCountry = await Navigator.push<Country>(
//                   context,
//                   CountriesPage.route(),
//                 );
//                 setState(() {});
//               },
//               child: selectedCountry == null
//                   ? Row(
//                       children: [
//                         Icon(iconError, color: Colors.red),
//                         formSpacer3,
//                         Text('Select Country'),
//                       ],
//                     )
//                   : Row(
//                       children: [
//                         Icon(iconSuccessfulOperation, color: Colors.green),
//                         formSpacer3,
//                         Text('Selected Country: ${selectedCountry!.name}'),
//                       ],
//                     ),
//             ),

//             /// If the assignement is for a club
//             if (widget.isClub == true)

//               /// Select the club to be reassigned
//               Column(
//                 children: [
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (selectedMultiverse == null ||
//                           selectedCountry == null) {
//                         context.showSnackBarError(
//                             'Please select a multiverse and a country before choosing your future club');
//                         return;
//                       }
//                       // Fetch a random league from the selected multiverse and continent
//                       int? idRandomLeague;
//                       try {
//                         final data = await supabase
//                             .from('leagues')
//                             .select('id')
//                             .eq('id_multiverse', selectedMultiverse!.id)
//                             .eq('continent',
//                                 selectedCountry!.selectedContinent!)
//                             .order('level', ascending: false)
//                             // .order('random()')
//                             .limit(1)
//                             .select();

//                         // Fetch the id of the league
//                         idRandomLeague = data[0]['id'] as int;
//                       } on PostgrestException catch (error) {
//                         context.showSnackBarPostgreSQLError(error.message);
//                         return;
//                       } catch (error) {
//                         context.showSnackBarError('ERROR: $error');
//                         return;
//                       }
//                       selectedClub = await Navigator.push<Club?>(
//                         context,
//                         LeaguePage.route(idRandomLeague,
//                             isReturningBotClub: true),
//                       );
//                       setState(() {});
//                     },
//                     child: selectedClub == null
//                         ? Row(
//                             children: [
//                               Icon(iconError, color: Colors.red),
//                               formSpacer3,
//                               Text('Select Club'),
//                             ],
//                           )
//                         : Row(
//                             children: [
//                               Icon(iconSuccessfulOperation,
//                                   color: Colors.green),
//                               formSpacer3,
//                               Text('Selected Club: ${selectedClub!.name}'),
//                             ],
//                           ),
//                   ),
//                   // TextFormField(
//                   //   controller: clubNameController,
//                   //   decoration: InputDecoration(
//                   //     labelText: 'New Club Name',
//                   //     hintText: 'Leave empty to change it later...',
//                   //   ),
//                   // ),
//                 ],
//               ),

//             /// If the assignement is for a player, show the first name, last name and age selection
//             if (widget.isClub == false)
//               Column(
//                 children: [
//                   TextFormField(
//                     controller: firstNameController,
//                     decoration: InputDecoration(
//                       labelText: 'First Name',
//                       hintText: 'First name of the player',
//                     ),
//                   ),
//                   TextFormField(
//                     controller: lastNameController,
//                     decoration: InputDecoration(
//                       labelText: 'Last Name',
//                       hintText: 'Last name of the player',
//                     ),
//                   ),
//                   formSpacer6,
//                   Text('Select Age:'),
//                   Slider(
//                     value: selectedAge,
//                     min: 15.0,
//                     max: 35.0,
//                     divisions: 200,
//                     label: selectedAge.toStringAsFixed(1),
//                     onChanged: (double value) {
//                       setState(() {
//                         selectedAge = value;
//                         if (selectedMultiverse != null) {
//                           dateBirth = DateTime.now().subtract(Duration(
//                               days: (selectedAge *
//                                       14 *
//                                       7 /
//                                       selectedMultiverse!.speed)
//                                   .round()));
//                         } else {
//                           dateBirth = null;
//                         }
//                       });
//                     },
//                   ),
//                   Text(
//                     'Selected Age: ${selectedAge.toStringAsFixed(1)}',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                   if (dateBirth != null)
//                     Text(
//                       'Birth Date: ${DateFormat('MMMM d, yyyy').format(dateBirth!)}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           child: Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () async {
//             // Check if all the required fields are filled
//             if (selectedMultiverse == null) {
//               context.showSnackBarError(
//                   'No multiverse selected, ${widget.isClub ? 'club assignement' : 'player creation'} aborted');
//               return;
//             }
//             if (selectedCountry == null) {
//               context.showSnackBarError(
//                   'No country selected, ${widget.isClub ? 'club assignement' : 'player creation'} aborted');
//               return;
//             }
//             if (widget.isClub) {
//               if (selectedClub == null) {
//                 context.showSnackBarError(
//                     'No club selected, club assignement aborted');
//                 return;
//               }
//               // // Update the club in the database
//               bool isOK =
//                   await operationInDB(context, 'UPDATE', 'clubs', data: {
//                 'username': Provider.of<SessionProvider>(context, listen: false)
//                     .user!
//                     .username,
//                 'id_country': selectedCountry!.id,
//               }, matchCriteria: {
//                 'id': selectedClub!.id,
//               });
//               print('isOK: $isOK');

//               if (isOK) {
//                 context.showSnackBarSuccess(
//                     'You are now the happy owner of a new club in ${selectedCountry!.name} in the continent: ${selectedCountry!.selectedContinent} !');
//                 Navigator.of(context).pop();
//               }
//             } else {
//               if (selectedCountry!.selectedContinent == null) {
//                 context.showSnackBarError(
//                     'ERROR: No continent selected, player creation aborted');
//                 return;
//               }
//               if (selectedCountry!.selectedContinent == 'Others') {
//                 context.showSnackBarError(
//                     'Cannot select country from continent "Others", player creation aborted');
//                 return;
//               }
//               if (dateBirth == null) {
//                 context.showSnackBarError(
//                     'Cannot select date of birth, player creation aborted');
//                 return;
//               }
//               if (await context.showConfirmationDialog(
//                       'Are you sure you want to create a new player (${firstNameController.text} ${lastNameController.text}) from ${selectedCountry!.name} ?') !=
//                   true) {
//                 context.showSnackBarError('Player creation aborted');
//                 return;
//               }

//               // Insert the player in the database
//               bool isOK =
//                   await operationInDB(context, 'INSERT', 'players', data: {
//                 'username': Provider.of<SessionProvider>(context, listen: false)
//                     .user!
//                     .username,
//                 'id_country': selectedCountry!.id,
//                 'id_multiverse': selectedMultiverse!.id,
//                 'first_name': firstNameController.text,
//                 'last_name': lastNameController.text,
//                 'date_birth': dateBirth!.toIso8601String(),
//                 'training_points_available': selectedAge * 2,
//               });
//               if (isOK) {
//                 context.showSnackBarSuccess(
//                     'You now incarne ${firstNameController.text} ${lastNameController.text} in the continent: ${selectedCountry!.selectedContinent} !');
//                 Navigator.of(context).pop();
//               }
//             }
//           },
//           child: widget.isClub ? Text('Assign Club') : Text('Create Player'),
//         ),
//       ],
//     );
//   }
// }
