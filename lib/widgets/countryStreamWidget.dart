import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';

Widget getCountryNameWidget(BuildContext context, int? idCountry) {
  if (idCountry == null) {
    return Text('ERROR: No country !');
  }

  return StreamBuilder<Map>(
    stream: supabase
        .from('countries')
        .stream(primaryKey: ['id'])
        .eq('id', idCountry)
        .map((maps) => maps
            .map((map) => {
                  'id': map['id'],
                  'continent': map['continent'],
                  'name': map['name'],
                  'iso2': map['iso2'],
                })
            .first),
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
        final country = snapshot.data!;
        if (country.isEmpty) {
          return Text('ERROR: Country with id ${idCountry} not found');
        }
        // Actual row with data
        return ListTile(
          onTap: () {
            // Navigator.push(
            //   context,
            //   CountryPage.route(country['id']),
            // );
          },
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Adjust border radius as needed
            side: const BorderSide(
              color: Colors.blueGrey, // Border color
            ),
          ),
          // leading: CountryFlag.fromCountryCode(
          //   shape: Rectangle(),
          //   country['iso2'],
          //   width: 36,
          //   height: 24,
          // ),
          title: Row(
            children: [
              CountryFlag.fromCountryCode(
                shape: Rectangle(),
                country['iso2'],
                width: 36,
                height: 24,
              ),
              Text(
                country['name'],
                // style: TextStyle(
                //   fontWeight: FontWeight.bold,
                // ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              // Icon(Icons.language, size: iconSizeSmall),
              Icon(Icons.public, size: iconSizeSmall),
              Text(country['continent'],
                  style: TextStyle(
                      fontStyle: FontStyle.italic, color: Colors.blueGrey)),
            ],
          ),
          // trailing: CountryFlag.fromCountryCode(
          //   shape: Rectangle(),
          //   country['iso2'],
          //   width: 48,
          //   height: 36,
          // ),
        );
      }
    },
  );
}
