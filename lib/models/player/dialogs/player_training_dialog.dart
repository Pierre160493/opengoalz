import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/postgresql_requests.dart';

class PlayerTrainingDialog extends StatefulWidget {
  final Player player;

  PlayerTrainingDialog({required this.player});

  @override
  _PlayerTrainingDialogState createState() => _PlayerTrainingDialogState();
}

class _PlayerTrainingDialogState extends State<PlayerTrainingDialog> {
  late List<double> trainingRatioOld;
  late List<int> trainingCoefNew;
  late List<double> trainingRatioNew;
  late List<TextEditingController> controllers;
  late bool _isModified = false;

  @override
  void initState() {
    super.initState();
    trainingRatioOld = _calculateRatio(widget.player.trainingCoef);
    trainingCoefNew = List.from(widget.player.trainingCoef);
    trainingRatioNew = _calculateRatio(trainingCoefNew);
    controllers = trainingCoefNew
        .map((value) => TextEditingController(text: value.toStringAsFixed(1)))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<double> _calculateRatio(List<int> trainingCoef) {
    int totalWeight = trainingCoef.reduce((a, b) => a + b);
    if (totalWeight == 0) {
      return List.filled(trainingCoef.length, 0.0);
    }
    return trainingCoef.map((value) => value / totalWeight).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: ListTile(
        leading: Icon(iconStats, color: Colors.green),
        title: Text(
            'Here is the targeted progression of ${widget.player.getFullName()}'),
        subtitle: Text(
          'The player will progress according to the following coef and based on your club\'s staff and coach',
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            for (int i = 0; i < 7; i++)
              ListTile(
                leading: Icon(iconStats),
                title: Text(
                  '${[
                    'Keeper',
                    'Defense',
                    'Passes',
                    'Playmaking',
                    'Winger',
                    'Scoring',
                    'Freekick'
                  ][i]}: ${widget.player.trainingCoef[i].toString()} [${(trainingRatioOld[i] * 100).toStringAsFixed(0)}%] ${_isModified ? ' --> ${(trainingRatioNew[i] * 100).toStringAsFixed(0)}%' : ''}',
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        if (trainingRatioNew[i] != trainingRatioOld[i])
                          Container(
                            height: 20, // Set the desired height here
                            child: LinearProgressIndicator(
                              value:
                                  max(trainingRatioNew[i], trainingRatioOld[i]),
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  trainingRatioNew[i] > trainingRatioOld[i]
                                      ? Colors.green
                                      : Colors.red),
                            ),
                          ),
                        Container(
                          height: 20, // Set the desired height here
                          child: LinearProgressIndicator(
                            value:
                                min(trainingRatioNew[i], trainingRatioOld[i]),
                            backgroundColor:
                                trainingRatioNew[i] != trainingRatioOld[i]
                                    ? Colors.transparent
                                    : Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          trainingCoefNew[i] = max(0, trainingCoefNew[i] - 1);
                          if (trainingCoefNew[i] ==
                              widget.player.trainingCoef[i]) {
                            for (int j = 0; j < trainingCoefNew.length; j++) {
                              _isModified = false;
                              if (trainingCoefNew[j] !=
                                  widget.player.trainingCoef[j]) {
                                _isModified = true;
                                break;
                              }
                            }
                          } else {
                            _isModified = true;
                          }
                          trainingRatioNew = _calculateRatio(trainingCoefNew);
                          controllers[i].text =
                              trainingCoefNew[i].toStringAsFixed(1);
                        });
                      },
                    ),
                    Container(
                      width: 60,
                      child: TextField(
                        controller: controllers[i],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onChanged: (value) {
                          setState(() {
                            int? parsedValue = int.tryParse(value);
                            if (parsedValue != null && parsedValue >= 0) {
                              trainingCoefNew[i] = parsedValue;
                              if (trainingCoefNew[i] ==
                                  widget.player.trainingCoef[i]) {
                                for (int j = 0;
                                    j < trainingCoefNew.length;
                                    j++) {
                                  _isModified = false;
                                  if (trainingCoefNew[j] !=
                                      widget.player.trainingCoef[j]) {
                                    _isModified = true;
                                    break;
                                  }
                                }
                              } else {
                                _isModified = true;
                              }
                              trainingRatioNew =
                                  _calculateRatio(trainingCoefNew);
                            } else {
                              controllers[i].text =
                                  trainingCoefNew[i].toStringAsFixed(1);
                            }
                          });
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.green),
                      onPressed: () {
                        setState(() {
                          trainingCoefNew[i] += 1;
                          if (trainingCoefNew[i] ==
                              widget.player.trainingCoef[i]) {
                            for (int j = 0; j < trainingCoefNew.length; j++) {
                              _isModified = false;
                              if (trainingCoefNew[j] !=
                                  widget.player.trainingCoef[j]) {
                                _isModified = true;
                                break;
                              }
                            }
                          } else {
                            _isModified = true;
                          }
                          trainingRatioNew = _calculateRatio(trainingCoefNew);
                          controllers[i].text =
                              trainingCoefNew[i].toStringAsFixed(1);
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            /// Save button
            TextButton(
              onPressed: _isModified
                  ? () async {
                      await operationInDB(context, 'UPDATE', 'players',
                          data: {'training_coef': trainingCoefNew},
                          matchCriteria: {'id': widget.player.id},
                          messageSuccess:
                              'Successfully updated the training coefficients for ${widget.player.getFullName()}');

                      Navigator.of(context).pop();
                    }
                  : null,
              child: Row(
                children: [
                  Icon(Icons.save,
                      color: _isModified ? Colors.green : Colors.grey),
                  Text('Save'),
                ],
              ),
            ),

            /// Reset Button
            TextButton(
              onPressed: _isModified
                  ? () {
                      setState(() {
                        trainingCoefNew = List.from(widget.player.trainingCoef);
                        trainingRatioNew = _calculateRatio(trainingCoefNew);
                        for (int i = 0; i < controllers.length; i++) {
                          controllers[i].text =
                              trainingCoefNew[i].toStringAsFixed(1);
                        }
                        _isModified = false;
                      });
                    }
                  : null,
              child: Row(
                children: [
                  Icon(Icons.arrow_back,
                      color: _isModified ? Colors.red : Colors.grey),
                  Text('Reset'),
                ],
              ),
            ),

            /// Close Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                children: [
                  Icon(Icons.close, color: Colors.red),
                  Text('Close'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
