import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/player/class/player.dart';

class PlayerNameTooltip extends StatelessWidget {
  final Player player;
  final bool isSurname;

  const PlayerNameTooltip({
    Key? key,
    required this.player,
    this.isSurname = false,
  }) : super(key: key);

  String _getPlayerNameString() {
    return isSurname
        ? player.surName == null
            ? 'No Surname'
            : player.surName!
        : '${player.firstName[0]}.${player.lastName.toUpperCase()}';
  }

  Widget _getPlayerNameTextWidget(BuildContext context) {
    return Text(
      _getPlayerNameString(),
      style: TextStyle(
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
      message: '${player.firstName} ${player.lastName.toUpperCase()}',
      child: _getPlayerNameTextWidget(context),
    );
  }
}
