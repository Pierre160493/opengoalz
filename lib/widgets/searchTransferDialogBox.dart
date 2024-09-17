import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/pages/countries_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

class AssignPlayerOrClubDialog extends StatefulWidget {
  AssignPlayerOrClubDialog();
  @override
  _AssignPlayerOrClubDialogState createState() =>
      _AssignPlayerOrClubDialogState();
}

class _AssignPlayerOrClubDialogState extends State<AssignPlayerOrClubDialog> {
  Multiverse? selectedMultiverse;
  Country? selectedCountry;
  final TextEditingController clubNameController = TextEditingController();
  final double minAge = 15.0;
  final double maxAge = 35.0;
  late double selectedMinAge;
  late double selectedMaxAge;
  DateTime? minDateBirth;
  DateTime? maxDateBirth;
  PlayerStatus selectedStatus = PlayerStatus.transferList;

  // New state variables for stat selection
  Map<String, RangeValues?> selectedStats = {
    'keeper': null,
    'defense': null,
    'passes': null,
    'playmaking': null,
    'winger': null,
    'scoring': null,
    'freekick': null,
  };

  @override
  void initState() {
    super.initState();
    fetchDefaultMultiverse();

    selectedMaxAge = maxAge;
    updateMinAgeAndBirthDate(minAge, 0);
    updateMaxAgeAndBirthDate(maxAge, 0);
  }

  Future<void> fetchDefaultMultiverse() async {
    final selectedClub =
        Provider.of<SessionProvider>(context, listen: false).user?.selectedClub;

    if (selectedClub == null) {
      context.showSnackBarError(
          'No club selected, cannot fetch default multiverse');
      return;
    }

    try {
      final multiverse = await Multiverse.fromId(selectedClub.idMultiverse);
      setState(() {
        selectedMultiverse = multiverse;
      });
    } catch (e) {
      context.showSnackBarError('Failed to fetch default multiverse');
    }
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
                MultiverseSelector(
                  selectedMultiverse: selectedMultiverse,
                  onMultiverseSelected: (multiverse) {
                    setState(() {
                      selectedMultiverse = multiverse;
                      updateMinAgeAndBirthDate(selectedMinAge, 0);
                      updateMaxAgeAndBirthDate(selectedMaxAge, 0);
                    });
                  },
                  onMultiverseReset: () {
                    setState(() {
                      selectedMultiverse = null;
                    });
                  },
                ),

                /// Select the country
                CountrySelector(
                  selectedCountry: selectedCountry,
                  onCountrySelected: (country) {
                    setState(() {
                      selectedCountry = country;
                    });
                  },
                  onCountryReset: () {
                    setState(() {
                      selectedCountry = null;
                    });
                  },
                ),

                /// Select the player status (all, transfer list, free player)
                StatusSelector(
                  selectedStatus: selectedStatus,
                  onStatusSelected: (status) {
                    setState(() {
                      selectedStatus = status;
                    });
                  },
                ),

                /// Select the age range
                _buildAgeSelector(),

                /// Select the stats
                ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: Colors.green, width: 2.0),
                    ),
                    title: ElevatedButton(
                      onPressed: () async {
                        // Filter the stats to include only those that are null
                        List<String> availableStats = selectedStats.entries
                            .where((entry) => entry.value == null)
                            .map((entry) => entry.key)
                            .toList();

                        String? selectedStat = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Select Stat'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: availableStats.map((String stat) {
                                    return ListTile(
                                      title: Text(
                                          stat.substring(0, 1).toUpperCase() +
                                              stat.substring(1)),
                                      onTap: () {
                                        Navigator.of(context).pop(stat);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        );

                        if (selectedStat != null &&
                            selectedStats[selectedStat] == null) {
                          setState(() {
                            selectedStats[selectedStat] = RangeValues(0, 100);
                          });
                        }
                        print(selectedStats);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.query_stats, color: Colors.green),
                          formSpacer6,
                          Text('Select stats'),
                        ],
                      ),
                    ),
                    subtitle: Column(
                      children: [
                        ...selectedStats.entries
                            .where((entry) => entry.value != null)
                            .map((entry) {
                          return Column(
                            children: [
                              ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  side: BorderSide(
                                      color: Colors.green, width: 1.0),
                                ),
                                title: Text(
                                    '${entry.key[0].toUpperCase()}${entry.key.substring(1)} [${entry.value!.start} - ${entry.value!.end}]'),
                                subtitle: RangeSlider(
                                  values: entry.value!,
                                  min: 0,
                                  max: 100,
                                  divisions: 200,
                                  labels: RangeLabels(
                                    entry.value!.start.toString(),
                                    entry.value!.end.toString(),
                                  ),
                                  onChanged: (RangeValues values) {
                                    setState(() {
                                      selectedStats[entry.key] = RangeValues(
                                          (values.start * 10).round() / 10,
                                          (values.end * 10).round() / 10);
                                    });
                                  },
                                ),
                                trailing: IconButton(
                                  tooltip:
                                      'Remove the ${entry.key.toUpperCase()} criteria',
                                  onPressed: () {
                                    setState(() {
                                      selectedStats[entry.key] = null;
                                    });
                                  },
                                  icon: Icon(Icons.delete_forever,
                                      color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    )),
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
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    formSpacer3,
                    Text('Cancel'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  // Check if all the required fields are filled
                  if (selectedMultiverse == null) {
                    context.showSnackBarError(
                        'No multiverse selected, cannot search players');
                    return;
                  }

                  if (minDateBirth == null || maxDateBirth == null) {
                    context.showSnackBarError(
                        'Cannot select date of birth, player creation aborted');
                    return;
                  }

                  // Update the club in the database
                  // bool isOK =
                  //     await operationInDB(context, 'INSERT', 'players', data: {
                  //   'username': Provider.of<SessionProvider>(context, listen: false)
                  //       .user!
                  //       .username,
                  //   'id_country': selectedCountry!.id,
                  //   'id_multiverse': selectedMultiverse!.id,
                  //   'date_birth': minDateBirth!.toIso8601String(),
                  // });
                  // if (isOK) {
                  //   context.showSnackBarSuccess(
                  //       'You now incarne a new player in ${selectedCountry!.name} in the continent: ${selectedCountry!.selectedContinent} !');
                  //   Navigator.of(context).pop();
                  // }
                },
                child: Row(
                  children: [
                    Icon(Icons.person_search, color: Colors.green),
                    formSpacer3,
                    Text('Search Players'),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildAgeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              'Age Range:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            formSpacer12,
            Text('[' +
                selectedMinAge.toString() +
                ' - ' +
                selectedMaxAge.toString() +
                ']'),
          ],
        ),
        subtitle: RangeSlider(
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
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                // Select player minimum age
                _buildAgeAdjustmentRow(
                  currentAge: selectedMinAge,
                  minAge: minAge,
                  maxAge: maxAge,
                  dateOfBirth: minDateBirth,
                  label: 'Min',
                  updateAge: updateMinAgeAndBirthDate,
                ),
                // Select player maximum age
                _buildAgeAdjustmentRow(
                  currentAge: selectedMaxAge,
                  minAge: minAge,
                  maxAge: maxAge,
                  dateOfBirth: maxDateBirth,
                  label: 'Max',
                  updateAge: updateMaxAgeAndBirthDate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildAgeAdjustmentRow({
  required double currentAge,
  required double minAge,
  required double maxAge,
  required DateTime? dateOfBirth,
  required String label,
  required Function(double, double) updateAge,
}) {
  return ListTile(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
      side: BorderSide(color: Colors.green, width: 1.0),
    ),
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            updateAge(currentAge, -1);
          },
          icon: Icon(
            Icons.keyboard_double_arrow_down,
            color: currentAge <= minAge ? Colors.red : null,
          ),
          tooltip: 'Lower $label age by 1',
        ),
        IconButton(
          onPressed: () {
            updateAge(currentAge, -0.1);
          },
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: currentAge <= minAge ? Colors.red : null,
          ),
          tooltip: 'Lower $label age by 0.1',
        ),
        Tooltip(
          message:
              '$label Age: $currentAge [${dateOfBirth != null ? DateFormat('MMMM d, yyyy').format(dateOfBirth) : 'Select multiverse for date of birth'}]',
          child: Text('$label Age: $currentAge'),
        ),
        IconButton(
          onPressed: () {
            updateAge(currentAge, 0.1);
          },
          icon: Icon(
            Icons.keyboard_arrow_up,
            color: currentAge >= maxAge ? Colors.red : null,
          ),
          tooltip: 'Increase $label age by 0.1',
        ),
        IconButton(
          onPressed: () {
            updateAge(currentAge, 1.0);
          },
          icon: Icon(
            Icons.keyboard_double_arrow_up,
            color: currentAge >= maxAge ? Colors.red : null,
          ),
          tooltip: 'Increase $label age by 1',
        ),
      ],
    ),
  );
}

class MultiverseSelector extends StatelessWidget {
  final Multiverse? selectedMultiverse;
  final Function(Multiverse?) onMultiverseSelected;
  final Function() onMultiverseReset;

  MultiverseSelector({
    required this.selectedMultiverse,
    required this.onMultiverseSelected,
    required this.onMultiverseReset,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: selectedMultiverse == null ? Colors.red : Colors.green,
            width: 2.0),
      ),
      title: ElevatedButton(
        onPressed: () async {
          final multiverse = await Navigator.push<Multiverse>(
            context,
            MultiversePage.route(
              1,
              isReturningMultiverse: true,
            ),
          );
          onMultiverseSelected(multiverse);
        },
        child: selectedMultiverse == null
            ? Row(
                children: [
                  Icon(iconError, color: Colors.red),
                  formSpacer6,
                  Text('Select Multiverse'),
                ],
              )
            : Row(
                children: [
                  Icon(iconSuccessfulOperation, color: Colors.green),
                  formSpacer6,
                  Text('Multiverse: ${selectedMultiverse!.name}'),
                ],
              ),
      ),
      trailing: selectedMultiverse == null
          ? null
          : IconButton(
              tooltip: 'Reset the selected multiverse',
              onPressed: onMultiverseReset,
              icon: Icon(Icons.delete_forever, color: Colors.red),
            ),
    );
  }
}

class CountrySelector extends StatelessWidget {
  final Country? selectedCountry;
  final Function(Country?) onCountrySelected;
  final Function() onCountryReset;

  CountrySelector({
    required this.selectedCountry,
    required this.onCountrySelected,
    required this.onCountryReset,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
            color: selectedCountry == null ? Colors.orange : Colors.green,
            width: 2.0),
      ),
      title: ElevatedButton(
        onPressed: () async {
          final country = await Navigator.push<Country>(
            context,
            CountriesPage.route(),
          );
          onCountrySelected(country);
        },
        child: selectedCountry == null
            ? Row(
                children: [
                  Icon(Icons.settings_suggest, color: Colors.orange),
                  formSpacer6,
                  Text('Country: Any'),
                ],
              )
            : Row(
                children: [
                  Icon(iconSuccessfulOperation, color: Colors.green),
                  formSpacer6,
                  Text('Country: ${selectedCountry!.name}'),
                ],
              ),
      ),
      trailing: selectedCountry == null
          ? null
          : IconButton(
              tooltip: 'Reset the selected country',
              onPressed: onCountryReset,
              icon: Icon(Icons.delete_forever, color: Colors.red),
            ),
    );
  }
}

enum PlayerStatus { all, transferList, freePlayer }

class StatusSelector extends StatefulWidget {
  final PlayerStatus selectedStatus;
  final Function(PlayerStatus) onStatusSelected;

  StatusSelector({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  _StatusSelectorState createState() => _StatusSelectorState();
}

class _StatusSelectorState extends State<StatusSelector> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.green, width: 2.0),
      ),
      title: ElevatedButton(
        onPressed: () async {
          showDialog<PlayerStatus>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Select Player Status'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: PlayerStatus.values.map((PlayerStatus status) {
                    return RadioListTile<PlayerStatus>(
                      title: _statusRow(status),
                      value: status,
                      groupValue: widget.selectedStatus,
                      onChanged: (PlayerStatus? value) {
                        if (value != null) {
                          Navigator.of(context).pop(value);
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ).then((PlayerStatus? value) {
            if (value != null) {
              setState(() {
                widget.onStatusSelected(value);
              });
            }
          });
        },
        child: _statusRow(widget.selectedStatus),
      ),
    );
  }

  Widget _statusRow(PlayerStatus status) {
    Widget icon;
    Widget text;
    switch (status) {
      case PlayerStatus.all:
        icon = Icon(Icons.join_full, color: Colors.green);
        text = Text('All');
      case PlayerStatus.transferList:
        icon = Icon(iconTransfers, color: Colors.green);
        text = Text('Transfer List');
      case PlayerStatus.freePlayer:
        icon = Icon(Icons.wallet_giftcard, color: Colors.green);
        text = Text('Free Player');
      default:
        icon = Icon(iconError, color: Colors.red);
        text = Text('Unknown');
    }
    return Row(children: [
      icon,
      formSpacer6,
      text,
    ]);
  }
}
