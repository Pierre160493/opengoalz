import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:opengoalz/models/playerStatsBest.dart';
import 'dart:math';

Widget getGameWeights(GamePlayerStatsBest gameBestStats) {
  return SingleChildScrollView(
    child: Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth * 0.5;
          double height = width * (111 / 74); // Maintain the aspect ratio

          return Container(
            width: width, // Set the width to the available width
            height: height, // Maintain the aspect ratio
            child: Stack(
              children: [
                SvgPicture.asset(
                  'assets/images/Football_field.svg', // Replace with your SVG file path
                  width: width, // Take up all available width
                  height: height, // Maintain aspect ratio
                  fit: BoxFit.cover,
                ),
                for (int i = 1; i <= 7; i++)
                  buildPositionedText(i, gameBestStats, width, height),
              ],
            ),
          );
        },
      ),
    ),
  );
}

Widget buildPositionedText(int weightIndex, GamePlayerStatsBest gameBestStats,
    double width, double height) {
  final positions = [
    {
      'top': 0.1 * height,
      'left': 0.1 * width,
      'tooltip': 'Left Defense',
      'text': gameBestStats.weights.leftDefense.toString()
    },
    {
      'top': 0.1 * height,
      'left': 0.4 * width,
      'tooltip': 'Central Defense',
      'text': gameBestStats.weights.centralDefense.toString()
    },
    {
      'top': 0.1 * height,
      'left': 0.9 * width,
      'tooltip': 'Right Defense',
      'text': gameBestStats.weights.rightDefense.toString()
    },
    {
      'top': 0.5 * height,
      'left': 0.4 * width,
      'tooltip': 'Midfield',
      'text': gameBestStats.weights.midfield.toString()
    },
    {
      'top': 0.9 * height,
      'left': 0.1 * width,
      'tooltip': 'Left Attack',
      'text': gameBestStats.weights.leftAttack.toString()
    },
    {
      'top': 0.9 * height,
      'left': 0.4 * width,
      'tooltip': 'Central Attack',
      'text': gameBestStats.weights.centralAttack.toString()
    },
    {
      'top': 0.9 * height,
      'left': 0.9 * width,
      'tooltip': 'Right Attack',
      'text': gameBestStats.weights.rightAttack.toString()
    },
  ];

  final positionData = positions[weightIndex - 1];

  return Positioned(
    top: positionData['top'] as double,
    left: positionData['left'] as double,
    child: Transform.rotate(
      angle: -30 * pi / 180, // Rotate the text
      child: Tooltip(
          message: positionData['tooltip'] as String?,
          child: Text(positionData['text'] as String,
              style: TextStyle(color: Colors.white))),
    ),
  );
}
