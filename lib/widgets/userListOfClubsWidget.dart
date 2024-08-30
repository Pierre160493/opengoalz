import 'package:flutter/material.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/countries_page.dart';

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

  Country? selectedCountry = await Navigator.push<Country>(
    context,
    CountriesPage.route(), // Pass the required speed parameter
  );

  if (selectedCountry != null) {
    // Handle the selected country (e.g., create a club with the specified country)
    print('Selected country: ${selectedCountry.name}');
  } else {
    // Handle the case when no country was selected
    print('No country selected');
  }
}
