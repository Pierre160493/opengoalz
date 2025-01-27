import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerTransferBidDialogBox.dart';
import 'package:opengoalz/widgets/tickingTime.dart';

class PlayerCardTransferWidget extends StatelessWidget {
  final Player player;

  const PlayerCardTransferWidget({Key? key, required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blueGrey),
      ),
      leading: Icon(
        iconTransfers,
        size: iconSizeMedium,
        color: Colors.green,
      ),
      title: Row(
        children: [
          if (player.transferBids.isEmpty)
            Text(
              'Starting price: ',
            ),
          if (player.transferBids.isNotEmpty)
            getClubNameClickable(
                context, null, player.transferBids.first.idClub),
          formSpacer6,
          Text(
            player.transferPrice!.abs().toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
      subtitle: tickingTimeWidget(player.dateBidEnd!),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PlayerTransferBidDialogBox(idPlayer: player.id);
          },
        );
      },
    );
  }
}
