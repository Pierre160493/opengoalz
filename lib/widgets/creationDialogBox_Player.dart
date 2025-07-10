import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/models/multiverse/multiverseChoiceListTile.dart';
import 'package:opengoalz/pages/countriesSelection_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/country_tile.dart';
import 'package:provider/provider.dart';

class CreationDialogBox_Player extends StatefulWidget {
  CreationDialogBox_Player();
  @override
  _CreationDialogBox_Player createState() => _CreationDialogBox_Player();
}

class _CreationDialogBox_Player extends State<CreationDialogBox_Player> {
  Multiverse? _selectedMultiverse;
  Country? _selectedCountry;
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
    final multiverse = await Multiverse.fromId(1);
    if (mounted) {
      setState(() {
        _selectedMultiverse = multiverse;
        if (_selectedMultiverse != null) {
          dateBirth = DateTime.now().subtract(Duration(
              days:
                  (selectedAge * 14 * 7 / _selectedMultiverse!.speed).round()));
        } else {
          dateBirth = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AlertDialog(
          title: Text('Create a new player'),
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
                    onMultiverseReset: () {
                      setState(() {
                        _selectedMultiverse = null;
                        dateBirth = null;
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
                              setState(() {
                                _selectedCountry = null;
                              });
                            },
                            icon: Icon(Icons.delete_forever, color: Colors.red),
                          ),
                    onTap: () async {
                      final selected = await Navigator.push<Country>(
                        context,
                        CountriesSelectionPage.route(),
                      );
                      if (selected != null) {
                        setState(() {
                          _selectedCountry = selected;
                        });
                      }
                    },
                  ),

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
                    child: persoCancelRow()),
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
                                'No multiverse selected, player creation aborted');
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          if (_selectedCountry == null) {
                            context.showSnackBarError(
                                'No country selected, player creation aborted');
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }

                          if (_selectedCountry!.selectedContinent == null) {
                            context.showSnackBarError(
                                'ERROR: No continent selected, player creation aborted');
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          if (_selectedCountry!.selectedContinent == 'Others') {
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

                          bool isOK = await operationInDB(
                            context,
                            'FUNCTION',
                            'players_create_player',
                            data: {
                              'inp_id_multiverse': _selectedMultiverse!.id,
                              'inp_id_club': null,
                              'inp_id_country': _selectedCountry!.id,
                              'inp_age': 15,
                              'inp_username': Provider.of<UserSessionProvider>(
                                      context,
                                      listen: false)
                                  .user
                                  .username,
                              'inp_stats': [0, 0, 0, 0, 0, 0, 0],
                              'inp_notes': 'New embodied player',
                              'inp_first_name': firstNameController.text,
                              'inp_last_name': lastNameController.text,
                            },
                            messageSuccess:
                                'You now embody ${firstNameController.text} ${lastNameController.text}, let wish him good fortune in his career !',
                          );

                          if (isOK) {
                            Navigator.of(context).pop();
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
                            Text('Create Player'),
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
