import 'dart:math';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/pages/countries_page.dart';
import 'package:opengoalz/pages/multiverse_page.dart';

class playerSearchDialogBox extends StatefulWidget {
  final PlayerSearchCriterias inputPlayerSearchCriterias;
  playerSearchDialogBox({required this.inputPlayerSearchCriterias});
  @override
  _playerSearchDialogBoxState createState() => _playerSearchDialogBoxState();
}

class _playerSearchDialogBoxState extends State<playerSearchDialogBox> {
  PlayerSearchCriterias playerSearchCriterias = PlayerSearchCriterias();

  @override
  void initState() {
    super.initState();
    playerSearchCriterias = widget.inputPlayerSearchCriterias;

    // Set the default multiverse and update the UI once it's set
    playerSearchCriterias.setDefaultMultiverse(context).then((_) {
      setState(() {});
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
                // MultiverseSelector(
                //   selectedMultiverse: playerSearchCriterias.multiverse,
                //   onMultiverseSelected: (multiverse) {
                //     setState(() {
                //       playerSearchCriterias.multiverse = multiverse;

                //       playerSearchCriterias.updateAgeAndBirthDate(true);
                //       playerSearchCriterias.updateAgeAndBirthDate(false);
                //     });
                //   },
                //   onMultiverseReset: () {
                //     setState(() {
                //       playerSearchCriterias.multiverse = null;
                //     });
                //   },
                // ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                        color: playerSearchCriterias.multiverse == null
                            ? Colors.red
                            : Colors.green,
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
                      setState(() {
                        playerSearchCriterias.multiverse = multiverse;

                        playerSearchCriterias.updateAgeAndBirthDate(true);
                        playerSearchCriterias.updateAgeAndBirthDate(false);
                      });
                    },
                    child: playerSearchCriterias.multiverse == null
                        ? Row(
                            children: [
                              Icon(iconError, color: Colors.red),
                              formSpacer6,
                              Text('Select Multiverse'),
                            ],
                          )
                        : Row(
                            children: [
                              Icon(iconSuccessfulOperation,
                                  color: Colors.green),
                              formSpacer6,
                              Text(
                                  'Multiverse: ${playerSearchCriterias.multiverse!.name}'),
                            ],
                          ),
                  ),
                  trailing: playerSearchCriterias.multiverse == null
                      ? null
                      : IconButton(
                          tooltip: 'Reset the selected multiverse',
                          onPressed: () {
                            setState(() {
                              playerSearchCriterias.multiverse = null;
                            });
                          },
                          icon: Icon(Icons.delete_forever, color: Colors.red),
                        ),
                ),

                /// Select the country
                CountrySelector(
                  selectedCountry: playerSearchCriterias.countries?.first,
                  onCountrySelected: (Country? country) {
                    setState(() {
                      if (country == null) {
                        playerSearchCriterias.countries = null;
                      } else {
                        playerSearchCriterias.countries = [country];
                      }
                    });
                  },
                  onCountryReset: () {
                    setState(() {
                      playerSearchCriterias.countries = null;
                    });
                  },
                ),

                /// Select the player status (all, transfer list, free player)
                // StatusSelector(
                //   selectedStatus: selectedStatus,
                //   onStatusSelected: (status) {
                //     setState(() {
                //       selectedStatus = status;
                //     });
                //   },
                // ),

                /// Select the age range
                playerSearchCriterias.ageSelector(context, setState),

                /// Select the stats
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.green, width: 2.0),
                  ),
                  title: ElevatedButton(
                    onPressed: () async {
                      // Filter the stats to include only those that are null
                      List<String> availableStats = playerSearchCriterias
                          .stats.entries
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
                          playerSearchCriterias.stats[selectedStat] == null) {
                        setState(() {
                          playerSearchCriterias.stats[selectedStat] =
                              RangeValues(0, 100);
                        });
                      }
                      print(playerSearchCriterias.stats);
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
                      ...playerSearchCriterias.stats.entries
                          .where((entry) => entry.value != null)
                          .map((entry) {
                        return Column(
                          children: [
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side:
                                    BorderSide(color: Colors.green, width: 1.0),
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
                                    playerSearchCriterias.stats[entry.key] =
                                        RangeValues(
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
                                    playerSearchCriterias.stats[entry.key] =
                                        null;
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
                  ),
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
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    formSpacer3,
                    Text('Cancel'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  // Check if all the required fields are filled
                  if (playerSearchCriterias.multiverse == null) {
                    context.showSnackBarError(
                        'No multiverse selected, cannot search players');
                    return;
                  }

                  Navigator.of(context).pop(playerSearchCriterias);
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
