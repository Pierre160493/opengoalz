import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/country.dart';

Widget getCountryListTile(BuildContext context, int? idCountry) {
  if (idCountry == null) {
    return Text('ERROR: No country !');
  }

  return StreamBuilder<Country>(
    stream: supabase
        .from('countries')
        .stream(primaryKey: ['id'])
        .eq('id', idCountry)
        .map((maps) => maps.map((map) => Country.fromMap(map)).first),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Placeholder row while loading
        return Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(),
            ),
          ],
        );

        // Row(
        //   children: [
        //     SizedBox(
        //       width: 16.0, // Same width as the icon
        //       height: 16.0, // Same height as the icon
        //       child: CircularProgressIndicator(
        //         strokeWidth: 2.0,
        //       ),
        //     ),
        //     SizedBox(width: 4.0), // Spacing between icon and text
        //     SizedBox(
        //       width: 100.0, // Adjust the width as needed
        //       child: Text(
        //         'Loading...', // Placeholder text
        //         style: TextStyle(
        //           fontWeight: FontWeight.bold,
        //           color: Colors.grey, // Placeholder text color
        //         ),
        //         overflow: TextOverflow.ellipsis,
        //       ),
        //     ),
        //   ],
        // );
      } else if (snapshot.hasError) {
        return Text('ERROR: ${snapshot.error}');
      } else {
        Country country = snapshot.data!;
        // Actual row with data
        return ListTile(
          title: Expanded(
            child: Text(
              country.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(Icons.public, size: iconSizeSmall),
              formSpacer3,
              Text(country.continents.first ?? 'Unknown',
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.blueGrey)),
            ],
          ),
          onTap: () {
            // Navigator.push(
            //   context,
            //   CountryPage.route(country['id']),
            // );
          },
          shape: shapePersoRoundedBorder(),
          // leading: getCountryFlag(country.iso2),
        );
      }
    },
  );
}

Widget getCountryFlag(String countryCode) {
  return CountryFlag.fromCountryCode(
    shape: Rectangle(),
    countryCode,
    width: 36 * 1.5,
    height: 24 * 1.5,
  );
}

Widget getCountryFlagAndNameWidget(Country country) {
  return Tooltip(
    message: 'Continent: ${country.continents.first ?? 'Unknown'}',
    child: Row(
      children: [
        getCountryFlag(country.iso2),
        formSpacer6,
        Expanded(
          child: Text(
            country.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
