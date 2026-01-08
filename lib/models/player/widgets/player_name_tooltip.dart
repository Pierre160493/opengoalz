import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';

class PlayerNameTooltip extends StatelessWidget {
  final Player player;
  final bool isSurname;
  final double? fontSize;

  const PlayerNameTooltip({
    Key? key,
    required this.player,
    this.isSurname = false,
    this.fontSize,
  }) : super(key: key);

  Widget _getPlayerNameTextWidget(BuildContext context, {double? fontSize}) {
    return Text(
      player.getPlayerNameString(),
      style: TextStyle(
        fontSize: fontSize ?? this.fontSize ?? fontSizeMedium,
        fontWeight: FontWeight.bold,
        color: player.isEmbodiedByCurrentUser
            ? colorIsMine
            : player.isPartOfClubOfCurrentUser
                ? colorIsSelected
                : null,
      ),
      overflow: TextOverflow.fade,
      maxLines: 1,
      softWrap: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '${player.firstName} ${player.lastName.toUpperCase()} (${player.id})',
      child: _getPlayerNameTextWidget(context, fontSize: fontSize),
    );
  }
}
