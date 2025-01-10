import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/pages/countries_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/countryListTile.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignPlayerOrClubDialog extends StatefulWidget {
  final isClub; // Should the assignement be for a club or a player
  AssignPlayerOrClubDialog({required this.isClub});
  @override
  _AssignPlayerOrClubDialogState createState() =>
      _AssignPlayerOrClubDialogState();
}

class _AssignPlayerOrClubDialogState extends State<AssignPlayerOrClubDialog> {
  Multiverse? _selectedMultiverse;
  Country? selectedCountry;
  Club? selectedClub;
  final TextEditingController clubNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  double selectedAge = 15.0;
  DateTime? dateBirth;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeMultiverse();
  }

  Future<void> initializeMultiverse() async {
    _selectedMultiverse = await Multiverse.fromId(1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AlertDialog(
          title: widget.isClub
              ? Text('Get a new club')
              : Text('Create a new player'),
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
                  ListTile(
                    leading: Icon(
                      iconMultiverseSpeed,
                      color: _selectedMultiverse == null
                          ? Colors.red
                          : Colors.green,
                    ),
                    shape: shapePersoRoundedBorder(_selectedMultiverse == null
                        ? Colors.red
                        : Colors.green),
                    title: Text(
                        _selectedMultiverse == null
                            ? 'Select Multiverse'
                            : _selectedMultiverse!.name,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: _selectedMultiverse == null
                        ? null
                        : Text('Selected multiverse',
                            style: styleItalicBlueGrey),
                    trailing: _selectedMultiverse == null
                        ? null
                        : IconButton(
                            tooltip: 'Reset the selected multiverse',
                            onPressed: () {
                              _selectedMultiverse = null;
                              setState(() {});
                            },
                            icon: Icon(Icons.delete_forever, color: Colors.red),
                          ),
                    onTap: () async {
                      _selectedMultiverse = await Navigator.push<Multiverse>(
                        context,
                        MultiversePage.route(
                          1,
                          isReturningMultiverse: true,
                        ),
                      );
                      setState(() {});
                    },
                  ),

                  /// Select the country
                  ListTile(
                    leading: Icon(
                      iconCountries,
                      color:
                          selectedCountry == null ? Colors.red : Colors.green,
                    ),
                    shape: shapePersoRoundedBorder(
                        selectedCountry == null ? Colors.red : Colors.green),
                    title: selectedCountry == null
                        ? Text('Select Country',
                            style: TextStyle(fontWeight: FontWeight.bold))
                        : getCountryFlagAndNameWidget(selectedCountry!),
                    subtitle: selectedCountry == null
                        ? null
                        : Text('Selected country', style: styleItalicBlueGrey),
                    trailing: selectedCountry == null
                        ? null
                        : IconButton(
                            tooltip: 'Reset the selected country',
                            onPressed: () {
                              selectedCountry = null;
                              setState(() {});
                            },
                            icon: Icon(Icons.delete_forever, color: Colors.red),
                          ),
                    onTap: () async {
                      selectedCountry = await Navigator.push<Country>(
                        context,
                        CountriesPage.route(),
                      );
                      setState(() {});
                    },
                  ),

                  /// If the assignement is for a club
                  if (widget.isClub == true)

                    // /// Select the club to be reassigned
                    ListTile(
                      leading: Icon(
                        icon_home,
                        color: selectedClub == null ? Colors.red : Colors.green,
                      ),
                      shape: shapePersoRoundedBorder(
                          selectedClub == null ? Colors.red : Colors.green),
                      title: Text(
                          selectedClub == null
                              ? 'Select Club'
                              : selectedClub!.name,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: selectedClub == null
                          ? null
                          : Text('Selected club', style: styleItalicBlueGrey),
                      trailing: selectedClub == null
                          ? null
                          : IconButton(
                              tooltip: 'Reset the selected club',
                              onPressed: () {
                                selectedClub = null;
                                setState(() {});
                              },
                              icon:
                                  Icon(Icons.delete_forever, color: Colors.red),
                            ),
                      onTap: () async {
                        if (_selectedMultiverse == null ||
                            selectedCountry == null) {
                          context.showSnackBarError(
                              'Please select a multiverse and a country before choosing your future club');
                          return;
                        }
                        // Fetch a random league from the selected multiverse and continent
                        int? idRandomLeague;
                        try {
                          final data = await supabase
                              .from('leagues')
                              .select('id')
                              .eq('id_multiverse', _selectedMultiverse!.id)
                              .eq('continent',
                                  selectedCountry!.selectedContinent!)
                              .order('level', ascending: false)
                              // .order('random()')
                              .limit(1)
                              .select();

                          // Fetch the id of the league
                          idRandomLeague = data[0]['id'] as int;
                        } on PostgrestException catch (error) {
                          context.showSnackBarPostgreSQLError(error.message);
                          return;
                        } catch (error) {
                          context.showSnackBarError('ERROR: $error');
                          return;
                        }
                        selectedClub = await Navigator.push<Club?>(
                          context,
                          LeaguePage.route(idRandomLeague,
                              isReturningBotClub: true),
                        );
                        setState(() {});
                      },
                    ),

                  /// If the assignement is for a player, show the first name, last name and age selection
                  if (widget.isClub == false)
                    Column(
                      children: [
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
                              if (_selectedMultiverse != null) {
                                dateBirth = DateTime.now().subtract(Duration(
                                    days: (selectedAge *
                                            14 *
                                            7 /
                                            _selectedMultiverse!.speed)
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
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: persoCancelRow),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          // Check if all the required fields are filled
                          if (_selectedMultiverse == null) {
                            context.showSnackBarError(
                                'No multiverse selected, ${widget.isClub ? 'club assignement' : 'player creation'} aborted');
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          if (selectedCountry == null) {
                            context.showSnackBarError(
                                'No country selected, ${widget.isClub ? 'club assignement' : 'player creation'} aborted');
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          if (widget.isClub) {
                            if (selectedClub == null) {
                              context.showSnackBarError(
                                  'No club selected, club assignement aborted');
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            // // Update the club in the database
                            bool isOK = await operationInDB(
                                context, 'UPDATE', 'clubs',
                                data: {
                                  'username': Provider.of<SessionProvider>(
                                          context,
                                          listen: false)
                                      .user!
                                      .username,
                                  'id_country': selectedCountry!.id,
                                },
                                matchCriteria: {
                                  'id': selectedClub!.id,
                                });
                            print('isOK: $isOK');

                            if (isOK) {
                              context.showSnackBarSuccess(
                                  'You are now the happy owner of a new club in ${selectedCountry!.name} in the continent: ${selectedCountry!.selectedContinent} !');
                              Navigator.of(context).pop();
                            }
                          } else {
                            if (selectedCountry!.selectedContinent == null) {
                              context.showSnackBarError(
                                  'ERROR: No continent selected, player creation aborted');
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            if (selectedCountry!.selectedContinent ==
                                'Others') {
                              context.showSnackBarError(
                                  'Cannot select country from continent "Others", player creation aborted');
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            if (dateBirth == null) {
                              context.showSnackBarError(
                                  'Cannot select date of birth, player creation aborted');
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            if (await context.showConfirmationDialog(
                                    'Are you sure you want to create a new player (${firstNameController.text} ${lastNameController.text}) from ${selectedCountry!.name} ?') !=
                                true) {
                              context
                                  .showSnackBarError('Player creation aborted');
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }

                            // Insert the player in the database
                            bool isOK = await operationInDB(
                                context, 'INSERT', 'players',
                                data: {
                                  'username': Provider.of<SessionProvider>(
                                          context,
                                          listen: false)
                                      .user!
                                      .username,
                                  'id_country': selectedCountry!.id,
                                  'id_multiverse': _selectedMultiverse!.id,
                                  'first_name': firstNameController.text,
                                  'last_name': lastNameController.text,
                                  'date_birth': dateBirth!.toIso8601String(),
                                  'training_points_available': selectedAge * 2,
                                });
                            if (isOK) {
                              context.showSnackBarSuccess(
                                  'You now incarne ${firstNameController.text} ${lastNameController.text} in the continent: ${selectedCountry!.selectedContinent} !');
                              Navigator.of(context).pop();
                            }
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                  child: isLoading
                      ? CircularProgressIndicator()
                      : Row(
                          children: [
                            Icon(
                              iconSuccessfulOperation,
                              color: Colors.green,
                            ),
                            formSpacer3,
                            widget.isClub
                                ? Text('Assign Club')
                                : Text('Create Player'),
                          ],
                        ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
