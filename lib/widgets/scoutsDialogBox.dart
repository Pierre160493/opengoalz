import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/player/players_page.dart';
import 'package:opengoalz/models/playerSearchCriterias.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScoutsDialog extends StatefulWidget {
  final Club club;

  ScoutsDialog({required this.club});

  @override
  _ScoutsDialogState createState() => _ScoutsDialogState();
}

class _ScoutsDialogState extends State<ScoutsDialog> {
  bool _isLoading = false;
  Map<String, dynamic> _playerWeigths = {
    'Keeper': {'value': 0, 'weight': 0.0},
    'Defense': {'value': 0, 'weight': 0.0},
    'Passing': {'value': 0, 'weight': 0.0},
    'Midfield': {'value': 0, 'weight': 0.0},
    'Winger': {'value': 0, 'weight': 0.0},
    'Scoring': {'value': 0, 'weight': 0.0},
    'Freekick': {'value': 0, 'weight': 0.0}
  };
  int _pointsToDistribute = 25;

  void updateWeights() {
    int totalValue = _playerWeigths.values
        .fold(0, (sum, item) => sum + (item['value'] as int));
    _playerWeigths.forEach((key, value) {
      value['weight'] = totalValue == 0 ? 0.0 : (value['value'] / totalValue);
      print('key: $key, value: ${value['value']}, weight: ${value['weight']}');
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return AlertDialog(
          title: Text('Scout a young player'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                minWidth: min(constraints.maxWidth * 0.8, maxWidth * 0.8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Points to distribute
                  ListTile(
                    title: Text('Points to distribute: $_pointsToDistribute'),
                    subtitle: Text(
                        'Points to be distributed to the player stats',
                        style: styleItalicBlueGrey),
                    leading: Icon(iconStats, color: Colors.green),
                    shape: shapePersoRoundedBorder(),
                  ),

                  /// Distributed points in the stats
                  ..._playerWeigths.keys.map((key) {
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${key}: ${_playerWeigths[key]['value']}'),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: _playerWeigths[key]['value'] < 1
                                    ? null
                                    : () {
                                        setState(() {
                                          _playerWeigths[key]['value'] =
                                              max<int>(
                                                  0,
                                                  _playerWeigths[key]['value'] -
                                                      1);
                                          _pointsToDistribute++;
                                          updateWeights();
                                        });
                                      },
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: _pointsToDistribute <= 0
                                    ? null
                                    : () {
                                        setState(() {
                                          _playerWeigths[key]['value']++;
                                          _pointsToDistribute--;
                                          updateWeights();
                                        });
                                      },
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Stack(
                        children: [
                          Container(
                            height: 3,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          Container(
                            height: 3,
                            width: _playerWeigths[key]['weight'] == 0
                                ? 120
                                : _playerWeigths[key]['weight'] * 120,
                            decoration: BoxDecoration(
                              color: _playerWeigths[key]['weight'] == 0
                                  ? Colors.red
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                      leading: Icon(iconStats, color: Colors.green),
                      shape: shapePersoRoundedBorder(),
                    );
                  }).toList(),
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
                if (_pointsToDistribute == 0)
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                            });

                            if (await context.showConfirmationDialog(
                                    'Are you sure you want to call the scouts for a young player ?') !=
                                true) {
                              context
                                  .showSnackBarError('Player creation aborted');
                              setState(() {
                                _isLoading = false;
                              });
                              return;
                            }
                            int? idNewPlayer;
                            try {
                              idNewPlayer = await supabase
                                  .rpc('players_create_player', params: {
                                'inp_id_multiverse': widget.club.idMultiverse,
                                'inp_id_club': widget.club.id,
                                'inp_id_country': widget.club.idCountry,
                                'inp_stats': [
                                  _playerWeigths['Keeper']['value'],
                                  _playerWeigths['Defense']['value'],
                                  _playerWeigths['Passing']['value'],
                                  _playerWeigths['Midfield']['value'],
                                  _playerWeigths['Winger']['value'],
                                  _playerWeigths['Scoring']['value'],
                                  _playerWeigths['Freekick']['value']
                                ],
                                'inp_age': 15,
                                'inp_notes': 'Young Scouted'
                              });
                            } on PostgrestException catch (error) {
                              context.showSnackBarPostgreSQLError(
                                  'PostgreSQL ERROR: ${error.message}');
                            } catch (error) {
                              context
                                  .showSnackBarError('Unknown ERROR: $error');
                            }

                            if (idNewPlayer != null) {
                              context.showSnackBarSuccess(
                                  'You now have a new player in the squad !');
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlayersPage(
                                      playerSearchCriterias:
                                          PlayerSearchCriterias(
                                              idPlayer: [idNewPlayer!]),
                                    ),
                                  ));
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          },
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Row(
                            children: [
                              Icon(
                                iconSuccessfulOperation,
                                color: Colors.green,
                              ),
                              formSpacer3,
                              Text('Call the scouts'),
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
