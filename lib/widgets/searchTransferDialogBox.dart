import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/pages/countries_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignPlayerOrClubDialog extends StatefulWidget {
  AssignPlayerOrClubDialog();
  @override
  _AssignPlayerOrClubDialogState createState() =>
      _AssignPlayerOrClubDialogState();
}

class _AssignPlayerOrClubDialogState extends State<AssignPlayerOrClubDialog> {
  Multiverse? selectedMultiverse;
  Country? selectedCountry;
  Club? selectedClub;
  final TextEditingController clubNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final double minAge = 15.0;
  final double maxAge = 35.0;
  late double selectedMinAge;
  late double selectedMaxAge;
  DateTime? minDateBirth;
  DateTime? maxDateBirth;

  @override
  void initState() {
    super.initState();
    selectedMinAge = minAge;
    selectedMaxAge = maxAge;
  }

  void updateMinAgeAndBirthDate(double value, double offset) {
    setState(() {
      selectedMinAge =
          min(maxAge, max(minAge, ((value + offset) * 10).round() / 10));
      if (selectedMinAge > selectedMaxAge) {
        selectedMaxAge = selectedMinAge;
      }
      if (selectedMultiverse != null) {
        minDateBirth =
            calculateDateBirth(selectedMinAge, selectedMultiverse!.speed);
      } else {
        minDateBirth = null;
      }
    });
  }

  void updateMaxAgeAndBirthDate(double value, double offset) {
    setState(() {
      selectedMaxAge =
          min(maxAge, max(minAge, ((value + offset) * 10).round() / 10));
      if (selectedMaxAge < selectedMinAge) {
        selectedMinAge = selectedMaxAge;
      }
      if (selectedMultiverse != null) {
        maxDateBirth =
            calculateDateBirth(selectedMaxAge, selectedMultiverse!.speed);
      } else {
        maxDateBirth = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return AlertDialog(
        title: Text('Search Players'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minWidth: min(constraints.maxWidth * 0.8, maxWidth * 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Select the multiverse
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        updateMinAgeAndBirthDate(selectedMinAge, 0);
                        updateMaxAgeAndBirthDate(selectedMaxAge, 0);
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
                                Icon(iconSuccessfulOperation,
                                    color: Colors.green),
                                formSpacer3,
                                Text(
                                    'Multiverse: ${selectedMultiverse!.speed}'),
                              ],
                            ),
                    ),

                    /// Reset the selected multiverse with a button
                    if (selectedMultiverse != null)
                      IconButton(
                          tooltip: 'Reset the selected multiverse',
                          onPressed: () {
                            setState(() {
                              selectedMultiverse = null;
                            });
                          },
                          icon: Icon(Icons.delete_forever, color: Colors.red)),
                  ],
                ),

                /// Select the country
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
                            Icon(Icons.settings_suggest, color: Colors.orange),
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

                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            updateMinAgeAndBirthDate(selectedMinAge, -1);
                          },
                          icon: Icon(
                            Icons.keyboard_double_arrow_down,
                            color: selectedMinAge <= minAge ? Colors.red : null,
                          ),
                          tooltip: 'Lower min age by 1',
                        ),
                        IconButton(
                          onPressed: () {
                            updateMaxAgeAndBirthDate(selectedMinAge, -0.1);
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: selectedMinAge <= minAge ? Colors.red : null,
                          ),
                          tooltip: 'Lower min age by 0.1',
                        ),
                        Tooltip(
                            message:
                                'Minimum Age: ${selectedMinAge} [${minDateBirth != null ? DateFormat('MMMM d, yyyy').format(minDateBirth!) : 'Select multiverse for date of birth'}]',
                            child: Text('Min Age: $selectedMinAge')),
                        IconButton(
                          onPressed: () {
                            updateMinAgeAndBirthDate(selectedMinAge, 0.1);
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_up,
                            color: selectedMinAge >= maxAge ? Colors.red : null,
                          ),
                          tooltip: 'Increase min age by 0.1',
                        ),
                        IconButton(
                          onPressed: () {
                            updateMinAgeAndBirthDate(selectedMinAge, 1.0);
                          },
                          icon: Icon(
                            Icons.keyboard_double_arrow_up,
                            color: selectedMinAge >= maxAge ? Colors.red : null,
                          ),
                          tooltip: 'Increase min age by 1',
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            updateMaxAgeAndBirthDate(selectedMaxAge, -1);
                          },
                          icon: Icon(Icons.keyboard_double_arrow_down,
                              color:
                                  selectedMaxAge <= minAge ? Colors.red : null),
                          tooltip: 'Lower max age by 1',
                        ),
                        IconButton(
                          onPressed: () {
                            updateMaxAgeAndBirthDate(selectedMaxAge, -0.1);
                          },
                          icon: Icon(Icons.keyboard_arrow_down,
                              color:
                                  selectedMaxAge <= minAge ? Colors.red : null),
                          tooltip: 'Lower max age by 0.1',
                        ),
                        Tooltip(
                            message:
                                'Maximum Age: ${selectedMaxAge} [${maxDateBirth != null ? DateFormat('MMMM d, yyyy').format(maxDateBirth!) : 'Select multiverse for date of birth'}]',
                            child: Text('Max Age: $selectedMaxAge')),
                        IconButton(
                          onPressed: () {
                            updateMaxAgeAndBirthDate(selectedMaxAge, 0.1);
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_up,
                            color: selectedMaxAge >= maxAge ? Colors.red : null,
                          ),
                          tooltip: 'Increase max age by 0.1',
                        ),
                        IconButton(
                          onPressed: () {
                            updateMaxAgeAndBirthDate(selectedMaxAge, 1.0);
                          },
                          icon: Icon(
                            Icons.keyboard_double_arrow_up,
                            color: selectedMaxAge >= maxAge ? Colors.red : null,
                          ),
                          tooltip: 'Increase max age by 1',
                        ),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(selectedMinAge, selectedMaxAge),
                      min: minAge,
                      max: maxAge,
                      divisions: (maxAge - minAge).toInt() * 10,
                      labels: RangeLabels(selectedMinAge.toStringAsFixed(1),
                          selectedMaxAge.toStringAsFixed(1)),
                      onChanged: (RangeValues values) {
                        updateMinAgeAndBirthDate(values.start, 0);
                        updateMaxAgeAndBirthDate(values.end, 0);
                      },
                    ),
                  ],
                ),
              ],
            ),
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
              // Check if all the required fields are filled
              if (selectedMultiverse == null) {
                context.showSnackBarError(
                    'No multiverse selected, player search aborted');
                return;
              }
              if (selectedCountry == null) {
                context.showSnackBarError(
                    'No country selected, player search aborted');
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
              if (minDateBirth == null) {
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
                'date_birth': minDateBirth!.toIso8601String(),
              });
              if (isOK) {
                context.showSnackBarSuccess(
                    'You now incarne a new player in ${selectedCountry!.name} in the continent: ${selectedCountry!.selectedContinent} !');
                Navigator.of(context).pop();
              }
            },
            child: Text('Search Players'),
          ),
        ],
      );
    });
  }
}
