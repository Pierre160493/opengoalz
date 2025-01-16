import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/game/class/game.dart';

Widget getScoreRowFromGame(Game game) {
  /// If the game is not played yet
  if (game.isPlaying == null)
    return Icon(Icons.sync, size: iconSizeSmall);
  else if (game.isPlaying == true)
    return Row(
      children: [
        Icon(Icons.av_timer, size: iconSizeSmall, color: Colors.green),
        Text('Game in progress', style: TextStyle(color: Colors.green)),
      ],
    );
  else if (game.scoreLeft == null && game.scoreRight == null)
    return Text('ERROR: Unknown left and right score of the game $game.id');
  else if (game.scoreRight == null)
    return Text('ERROR: Unknown left score of the game $game.id');
  else if (game.scoreRight == null)
    return Text('ERROR: Unknown right score of the game $game.id');

  return getScoreRowFromScore(game.isLeftForfeit ? -1 : game.scoreLeft!,
      game.isRightForfeit ? -1 : game.scoreRight!, game.isCup,
      scorePenaltyLeft: game.scorePenaltyLeft,
      scorePenaltyRight: game.scorePenaltyRight,
      isLeftClubSelected: game.isLeftClubSelected);
}

Widget getScoreRowFromScore(
  int scoreLeft,
  int scoreRight,
  bool isCup, {
  int? scorePenaltyLeft,
  int? scorePenaltyRight,
  bool? isLeftClubSelected,
}) {
  /// Default white colors
  Color leftColor = Colors.white;
  Color rightColor = Colors.white;
  Color colorLeftPenalty = Colors.white;
  Color colorRightPenalty = Colors.white;

  /// If the left club is selected
  if (isLeftClubSelected == true) {
    if (scoreLeft > scoreRight) {
      leftColor = Colors.green;
      rightColor = Colors.green;
    } else if (scoreLeft < scoreRight) {
      leftColor = Colors.red;
      rightColor = Colors.red;
    } else if (scoreLeft == scoreRight) {
      leftColor = Colors.blueGrey;
      rightColor = Colors.blueGrey;
    }
    // if (isCup && scorePenaltyLeft != null && scorePenaltyRight != null) {
    if (scorePenaltyLeft != null && scorePenaltyRight != null) {
      if (scorePenaltyLeft > scorePenaltyRight) {
        colorLeftPenalty = Colors.green;
        colorRightPenalty = Colors.green;
      } else {
        colorLeftPenalty = Colors.red;
        colorRightPenalty = Colors.red;
      }
    }
  }

  /// If the right club is selected
  else if (isLeftClubSelected == false) {
    if (scoreLeft > scoreRight) {
      leftColor = Colors.red;
      rightColor = Colors.red;
    } else if (scoreLeft < scoreRight) {
      leftColor = Colors.green;
      rightColor = Colors.green;
    } else if (scoreLeft == scoreRight) {
      leftColor = Colors.blueGrey;
      rightColor = Colors.blueGrey;
    }
    // if (isCup && scorePenaltyLeft != null && scorePenaltyRight != null) {
    if (scorePenaltyLeft != null && scorePenaltyRight != null) {
      if (scorePenaltyLeft > scorePenaltyRight) {
        colorLeftPenalty = Colors.red;
        colorRightPenalty = Colors.red;
      } else {
        colorLeftPenalty = Colors.green;
        colorRightPenalty = Colors.green;
      }
    }
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      // color: Colors.black,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.blueGrey),
    ),
    child: Row(
      children: [
        Text(
          // If the score is -1, display 0F for forfeit
          scoreLeft == -1 ? '0(F)' : scoreLeft.toString(),
          style: TextStyle(
            // color: scorePenaltyLeft == null ? colorLeftPenalty : null,
            color: leftColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (scorePenaltyLeft != null)
          Text(
            ' [${scorePenaltyLeft.toString()}]',
            style: TextStyle(
              color: colorLeftPenalty,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          ' : ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
        if (scorePenaltyRight != null)
          Text(
            '[${scorePenaltyRight.toString()}] ',
            style: TextStyle(
              color: colorRightPenalty,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          scoreRight == -1 ? '0(F)' : scoreRight.toString(),
          style: TextStyle(
            // color: scorePenaltyRight == null ? colorRightPenalty : null,
            color: rightColor,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    ),
  );
}
