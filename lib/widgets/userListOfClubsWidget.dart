import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/countries_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';

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

  /// Multiverse selection
  Multiverse? selectedMultiverse = await Navigator.push<Multiverse>(
    context,
    MultiversePage.route(
      1,
      isReturningMultiverse: true,
    ),
  );

  /// Check selection and ask confirmation
  if (selectedMultiverse == null) {
    context.showSnackBarError('No multiverse selected, club selection aborted');
    return;
  } else {
    if (await context.showConfirmationDialog(
            'Are you sure you want to select a club in the multiverse with speed ${selectedMultiverse.speed} ?') ==
        false) {
      context.showSnackBarError('Club selection aborted');
      return;
    }
  }

  Country? selectedCountry = await Navigator.push<Country>(
    context,
    CountriesPage.route(), // Pass the required speed parameter
  );

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
  print('Selected country: ${selectedCountry.name}');
}
