import 'dart:math';
import 'package:flutter/material.dart';
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

class CreationDialogBox_Club extends StatefulWidget {
  @override
  _CreationDialogBox_Club createState() => _CreationDialogBox_Club();
}

class _CreationDialogBox_Club extends State<CreationDialogBox_Club> {
  Multiverse? _selectedMultiverse;
  Country? _selectedCountry;
  Club? _selectedClub;
  final TextEditingController clubNameController = TextEditingController();
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
          title: Text('Get a new club'),
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
                              setState(() {
                                _selectedCountry = null;
                              });
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

                  /// Select the club to be reassigned
                  ListTile(
                    leading: Icon(
                      iconHome,
                      color: _selectedClub == null ? Colors.red : Colors.green,
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
                            icon: Icon(Icons.delete_forever, color: Colors.red),
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
                                'No multiverse selected, club assignement aborted');
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          if (_selectedCountry == null) {
                            context.showSnackBarError(
                                'No country selected, club assignement aborted');
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }

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
                                'username': Provider.of<UserSessionProvider>(
                                        context,
                                        listen: false)
                                    .user
                                    .username,
                                'id_country': _selectedCountry!.id,
                              },
                              matchCriteria: {
                                'id': _selectedClub!.id,
                              });

                          if (isOK) {
                            context.showSnackBarSuccess(
                                'You are now the happy owner of a new club in ${_selectedCountry!.name} in the continent: ${_selectedCountry!.selectedContinent} !');
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
                            Text('Assign Club')
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
