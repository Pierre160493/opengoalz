import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/pages/continent_page.dart';
import 'package:opengoalz/pages/country_page.dart';

// Widget getCountryListTile(BuildContext context, int? idCountry) {
//   return ListTile(
//     // title: Expanded(
//     //   child: Text(
//     //     idCountry.toString(),
//     //     style: TextStyle(
//     //       fontWeight: FontWeight.bold,
//     //     ),
//     //     overflow: TextOverflow.ellipsis,
//     //   ),
//     // ),
//     title: Text(
//       idCountry.toString(),
//       style: TextStyle(
//         fontWeight: FontWeight.bold,
//       ),
//       overflow: TextOverflow.ellipsis,
//     ),
//     subtitle: Text('Country (a corriger)', style: styleItalicBlueGrey),
//     shape: shapePersoRoundedBorder(),
//     leading: Icon(Icons.public, color: Colors.green),
//   );
// }

Widget getCountryListTileFromIdCountry(
    BuildContext context, int? idCountry, int? idMultiverse) {
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
      } else if (snapshot.hasError) {
        return Text('ERROR: ${snapshot.error}');
      } else {
        Country country = snapshot.data!;
        // Actual row with data
        return getCountryListTileFromCountry(context, country, idMultiverse);
      }
    },
  );
}

Widget getCountryListTileFromCountry(
    BuildContext context, Country country, int? idMultiverse,
    {bool isClickable = true}) {
  return ListTile(
    title: Text(
      country.name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    subtitle: Row(
      children: [
        Icon(Icons.public, size: iconSizeSmall),
        formSpacer3,
        InkWell(
          onTap: country.continents.first == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    ContinentPage.route(country.continents.first!,
                        idMultiverse: idMultiverse),
                  );
                },
          child: Text(country.continents.first ?? 'Unknown',
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.blueGrey)),
        ),
      ],
    ),
    onTap: isClickable == false
        ? null
        : () {
            Navigator.push(
              context,
              CountryPage.route(country.id, idMultiverse: idMultiverse),
            );
          },
    shape: shapePersoRoundedBorder(),
    leading: getCountryFlag(country.iso2),
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
