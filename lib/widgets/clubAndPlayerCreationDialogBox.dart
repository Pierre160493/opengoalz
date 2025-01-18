import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/multiverse/multiverseChoiceListTile.dart';
import 'package:opengoalz/pages/countriesSelection_page.dart';
import 'package:opengoalz/pages/league_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/countryListTile.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignPlayerOrClubDialogBox extends StatefulWidget {
  final isClub; // Should the assignement be for a club or a player
  AssignPlayerOrClubDialogBox({required this.isClub});
  @override
  _AssignPlayerOrClubDialogBoxState createState() =>
      _AssignPlayerOrClubDialogBoxState();
}

class _AssignPlayerOrClubDialogBoxState
    extends State<AssignPlayerOrClubDialogBox> {
  Multiverse? _selectedMultiverse;
  Country? _selectedCountry;
  Club? _selectedClub;
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
          title: Text(widget.isClub ? 'Get a new club' : 'Create a new player'),
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
                  MultiverseChoiceListTile(
                    selectedMultiverse: _selectedMultiverse,
                    onMultiverseSelected: (multiverse) {
                      setState(() {
                        _selectedMultiverse = multiverse;
                      });
                    },
                    onMultiverseReset: () {
                      setState(() {
                        _selectedMultiverse = null;
                      });
                    },
                  ),

                  /// Select the country
                  ListTile(
                    leading: Icon(
                      iconCountries,
                      color:
                          _selectedCountry == null ? Colors.red : Colors.green,
                    ),
                    shape: shapePersoRoundedBorder(
                        _selectedCountry == null ? Colors.red : Colors.green),
                    title: _selectedCountry == null
                        ? Text('Select Country',
                            style: TextStyle(fontWeight: FontWeight.bold))
                        : getCountryFlagAndNameWidget(_selectedCountry!),
                    subtitle: _selectedCountry == null
                        ? null
                        : Text('Selected country', style: styleItalicBlueGrey),
                    trailing: _selectedCountry == null
                        ? null
                        : IconButton(
                            tooltip: 'Reset the selected country',
                            onPressed: () {
                              _selectedCountry = null;
                              setState(() {});
                            },
                            icon: Icon(Icons.delete_forever, color: Colors.red),
                          ),
                    onTap: () async {
                      _selectedCountry = await Navigator.push<Country>(
                        context,
                        CountriesSelectionPage.route(),
                      );
                      setState(() {});
                    },
                  ),

                  /// If the assignement is for a club
                  if (widget.isClub == true)

                    // /// Select the club to be reassigned
                    ListTile(
                      leading: Icon(
                        iconHome,
                        color:
                            _selectedClub == null ? Colors.red : Colors.green,
                      ),
                      shape: shapePersoRoundedBorder(
                          _selectedClub == null ? Colors.red : Colors.green),
                      title: Text(
                          _selectedClub == null
                              ? 'Select Club'
                              : _selectedClub!.name,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: _selectedClub == null
                          ? null
                          : Text('Selected club', style: styleItalicBlueGrey),
                      trailing: _selectedClub == null
                          ? null
                          : IconButton(
                              tooltip: 'Reset the selected club',
                              onPressed: () {
                                _selectedClub = null;
                                setState(() {});
                              },
                              icon:
                                  Icon(Icons.delete_forever, color: Colors.red),
                            ),
                      onTap: () async {
                        if (_selectedMultiverse == null ||
                            _selectedCountry == null) {
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
                                  _selectedCountry!.selectedContinent!)
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
                        _selectedClub = await Navigator.push<Club?>(
                          context,
                          LeaguePage.route(idRandomLeague,
                              isReturningBotClub: true),
                        );

                        /// Reset the selected multiverse if the club is not from the currently selected multiverse
                        if (_selectedClub != null &&
                            _selectedMultiverse != null) {
                          if (_selectedClub!.idMultiverse !=
                              _selectedMultiverse!.id) {
                            _selectedMultiverse = null;
                          }
                        }
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
                          if (_selectedCountry == null) {
                            context.showSnackBarError(
                                'No country selected, ${widget.isClub ? 'club assignement' : 'player creation'} aborted');
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          if (widget.isClub) {
                            if (_selectedClub == null) {
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
                                  'id_country': _selectedCountry!.id,
                                },
                                matchCriteria: {
                                  'id': _selectedClub!.id,
                                });
                            print('isOK: $isOK');

                            if (isOK) {
                              context.showSnackBarSuccess(
                                  'You are now the happy owner of a new club in ${_selectedCountry!.name} in the continent: ${_selectedCountry!.selectedContinent} !');
                              Navigator.of(context).pop();
                            }
                          } else {
                            if (_selectedCountry!.selectedContinent == null) {
                              context.showSnackBarError(
                                  'ERROR: No continent selected, player creation aborted');
                              setState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            if (_selectedCountry!.selectedContinent ==
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
                                    'Are you sure you want to create a new player (${firstNameController.text} ${lastNameController.text}) from ${_selectedCountry!.name} ?') !=
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
                                  'id_country': _selectedCountry!.id,
                                  'id_multiverse': _selectedMultiverse!.id,
                                  'first_name': firstNameController.text,
                                  'last_name': lastNameController.text,
                                  'date_birth': dateBirth!.toIso8601String(),
                                  'training_points_available': selectedAge * 2,
                                });
                            if (isOK) {
                              context.showSnackBarSuccess(
                                  'You now incarne ${firstNameController.text} ${lastNameController.text} in the continent: ${_selectedCountry!.selectedContinent} !');
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
