import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/countries_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Widget clubListWidget(BuildContext context, Profile user) {
  // If user has no club, show the ListTile with possibility of creating a club
  if (user.clubs.isEmpty) {
    return ListTile(
      leading: const Icon(Icons.cancel, color: Colors.red),
      title: const Text('You dont have any club yet'),
      subtitle: const Text(
          'Create a club to start your aventure and show your skills !',
          style:
              TextStyle(color: Colors.blueGrey, fontStyle: FontStyle.italic)),
      trailing: IconButton(
        tooltip: 'Get a club',
        icon: const Icon(
          Icons.add,
          color: Colors.green,
        ),
        onPressed: () {
          _assignClub(context);
        },
      ),
    );
  }
  return Column(
    children: [
      const SizedBox(height: 12),
      Expanded(
        child: ListView.builder(
          itemCount: user.clubs.length,
          itemBuilder: (context, index) {
            final Club club = user.clubs[index];
            return club.getClubCard(context, index);
          },
        ),
      ),
    ],
  );
}

Future<void> _assignClub(BuildContext context) async {
  // Ask the mutliverse speed to the user

  context.showSnackBarSuccess(
      'Please select the multiverse in which you want to play');

  /// Multiverse selection
  Multiverse? selectedMultiverse = await Navigator.push<Multiverse>(
    context,
    MultiversePage.route(
      1,
      isReturningMultiverse: true,
    ),
  );
  // Check selection and ask confirmation
  if (selectedMultiverse == null) {
    context.showSnackBarError('No multiverse selected, club selection aborted');
    return;
  }

  /// Country selection
  Country? selectedCountry = await Navigator.push<Country>(
    context,
    CountriesPage.route(), // Pass the required speed parameter
  );
  // Check selection and ask confirmation
  if (selectedCountry == null) {
    context.showSnackBarError('No country selected, club selection aborted');
    return;
  } else {
    if (selectedCountry.selectedContinent == null) {
      context.showSnackBarError(
          'ERROR: No continent selected, club selection aborted');
      return;
    } else if (selectedCountry.selectedContinent == 'Others') {
      context.showSnackBarError(
          'Cannot select country from continent "Others", club selection aborted');
      return;
    } else {
      if (await context.showConfirmationDialog(
              'Are you sure you want to select a club in ${selectedCountry.name} in the continent: ${selectedCountry.selectedContinent} ?') !=
          true) {
        context.showSnackBarError('Club selection aborted');
        return;
      }
    }
  }

  int? idRandomLeague;

  try {
    final data = await supabase
        .from('leagues')
        .select('id')
        .eq('id_multiverse', selectedMultiverse.id)
        .eq('continent', selectedCountry.selectedContinent!)
        .order('level', ascending: false)
        // .order('random()')
        .limit(1)
        .select();
    print('data here');
    print(data);

    idRandomLeague = 1;
  } on PostgrestException catch (error) {
    context.showSnackBarPostgreSQLError(error.message);
    return;
  } catch (error) {
    context.showSnackBarError('Unknown ERROR: $error');
    return;
  }

  print('Selected country: ${selectedCountry.name}');
  // Show the League Page to pick a bot club
  // Club? selectedClub = await Navigator.push<Club?>(
  //   context,
  //   LeaguePage.route(idRandomLeague, isReturningBotClub: true),
  // );

  // // Update the club in the database
  // bool isOK = await operationInDB(context, 'UPDATE', 'clubs', data: {
  //   'username': Provider.of<SessionProvider>(context).user!.username,
  // }, matchCriteria: {
  //   'id': '1'
  // });
  // if (isOK) {
  //   context.showSnackBarSuccess(
  //       'You are now the happy owner of a new club in ${selectedCountry.name} in the continent: ${selectedCountry.selectedContinent} !');
  // }
}
