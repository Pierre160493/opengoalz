import 'dart:math';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/country.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/pages/countriesSelection_page.dart';
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

                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.green, width: 2.0),
                  ),
                  title: ElevatedButton(
                    onPressed: () async {
                      // Filter the stats to include only those that are null
                      final country = await Navigator.push<Country>(
                        context,
                        CountriesSelectionPage.route(),
                      );
                      if (country != null) {
                        setState(() {
                          playerSearchCriterias.countries.add(country);
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Icon(iconCountries, color: Colors.green),
                        formSpacer6,
                        Text(playerSearchCriterias.countries.isEmpty
                            ? 'Select a country'
                            : 'Add a country'),
                      ],
                    ),
                  ),
                  subtitle: Column(
                    children: [
                      if (playerSearchCriterias.countries.isNotEmpty)
                        formSpacer3,
                      ...playerSearchCriterias.countries.map((Country country) {
                        return Column(
                          children: [
                            ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side:
                                    BorderSide(color: Colors.green, width: 1.0),
                              ),
                              title: Text('${country.name}'),
                              trailing: IconButton(
                                tooltip:
                                    'Remove ${country.name} from the search criteria',
                                onPressed: () {
                                  setState(() {
                                    playerSearchCriterias.countries
                                        .remove(country);
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

                /// Select the player status (all, transfer list, free player)
                // StatusSelector(
                //   selectedStatus: selectedStatus,
                //   onStatusSelected: (status) {
                //     setState(() {
                //       selectedStatus = status;
                //     });
                //   },
                // ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.green, width: 2.0),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.signpost, color: Colors.green),
                      formSpacer6,
                      Text('Player Status'),
                    ],
                  ),
                  subtitle: Column(
                    children: [
                      /// Player is on transfer list
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Colors.green, width: 1.0),
                        ),
                        title: Row(
                          children: [
                            Icon(iconTransfers, color: Colors.green),
                            formSpacer6,
                            Text('On Transfer List'),
                          ],
                        ),
                        trailing: Switch(
                          value: playerSearchCriterias.onTransferList,
                          onChanged: (bool value) {
                            setState(() {
                              playerSearchCriterias.onTransferList = value;
                            });
                          },
                        ),
                      ),

                      /// Player is retired
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Colors.green, width: 1.0),
                        ),
                        title: Row(
                          children: [
                            Icon(iconRetired, color: Colors.green),
                            formSpacer6,
                            Text('Retired'),
                          ],
                        ),
                        trailing: Switch(
                          value: playerSearchCriterias.retired,
                          onChanged: (bool value) {
                            setState(() {
                              playerSearchCriterias.retired = value;

                              /// If retired, increase the age range
                              if (playerSearchCriterias.retired) {
                                playerSearchCriterias.defaultMinAge = 0;
                                playerSearchCriterias.defaultMaxAge = 99;
                              }
                            });
                          },
                        ),
                      ),
                      // ListTile(
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(12.0),
                      //     side: BorderSide(color: Colors.green, width: 1.0),
                      //   ),
                      //   title: Row(
                      //     children: [
                      //       Icon(Icons.logout, color: Colors.green),
                      //       formSpacer6,
                      //       Text('Free Player'),
                      //     ],
                      //   ),
                      //   trailing: Switch(
                      //     value: playerSearchCriterias.isFreePlayer,
                      //     onChanged: (bool value) {
                      //       setState(() {
                      //         playerSearchCriterias.isFreePlayer = value;
                      //       });
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),

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
                        Icon(iconStats, color: Colors.green),
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
                child: persoCancelRow,
              ),
              FutureBuilder<List<int>>(
                future: playerSearchCriterias.fetchPlayerIds(),
                builder: (context, snapshot) {
                  bool tooManyResults =
                      snapshot.hasData && snapshot.data!.length > 999;
                  return TextButton(
                    onPressed: () {
                      if (tooManyResults) {
                        context.showSnackBarError(
                            'Too many results. Please add more filters to narrow down the search.');
                        return;
                      }

                      // Check if all the required fields are filled
                      if (playerSearchCriterias.multiverse == null) {
                        context.showSnackBarError(
                            'No multiverse selected, cannot search players');
                        return;
                      }

                      // playerSearchCriterias.fetchPlayerIds();

                      Navigator.of(context).pop(playerSearchCriterias);
                    },
                    child: Row(
                      children: [
                        // if (snapshot.connectionState == ConnectionState.waiting)
                        //   CircularProgressIndicator(),
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) ...[
                          LoadingIndicator(),
                        ] else if (snapshot.hasError) ...[
                          Row(
                            children: [
                              Icon(iconError, color: Colors.red),
                              formSpacer3,
                              Text('Error fetching players'),
                            ],
                          ),
                        ] else if (snapshot.hasData) ...[
                          Tooltip(
                            message: tooManyResults
                                ? 'Too many results. Please add more filters to narrow down the search.'
                                : 'Search for players',
                            child: Row(
                              children: [
                                Icon(Icons.person_search,
                                    color: tooManyResults
                                        ? Colors.red
                                        : Colors.green),
                                formSpacer3,
                                Text('Search '),
                                Text(
                                  tooManyResults
                                      ? '999+'
                                      : snapshot.data!.length.toString(),
                                  style: TextStyle(
                                    color: tooManyResults
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                                Text(' Players'),
                              ],
                            ),
                          ),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      );
    });
  }
}

class LoadingIndicator extends StatefulWidget {
  @override
  _LoadingIndicatorState createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2.0 * pi,
              child: child,
            );
          },
          child: Icon(Icons.hourglass_empty, color: Colors.green),
        ),
        SizedBox(width: 8),
        Text('Pre loading players'),
      ],
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
