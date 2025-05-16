import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/getClubNameWidget.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/models/player/playerEmbodiedOfferDialogBox.dart';
import 'package:opengoalz/models/player/playerTransferBidDialogBox.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/widgets/tickingTime.dart';

class PlayerCardTransferWidget extends StatelessWidget {
  final Player player;

  const PlayerCardTransferWidget({Key? key, required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Choose tile builder based on player.userName presence
    return (player.userName != null)
        ? _buildEmbodiedPlayerTile(context, player)
        : _buildTransferListTile(context, player);
  }

  Widget _buildEmbodiedPlayerTile(BuildContext context, Player player) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blueGrey),
      ),
      leading: Icon(
        iconUser,
        size: iconSizeMedium,
        color: Colors.blue,
      ),
      title: Row(
        children: [
          Text(
            'Embodied player',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            'User: ',
            style: styleItalicBlueGrey,
          ),
          getUserNameClickable(context, userName: player.userName),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          iconTransfers,
          size: iconSizeMedium,
          color: Colors.green,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return PlayerEmbodiedOfferDialogBox(idPlayer: player.id);
            },
          );
        },
        iconSize: iconSizeMedium,
        color: Colors.green,
      ),
    );
  }

  Widget _buildTransferListTile(BuildContext context, Player player) {
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
            player.transferPrice != null
                ? player.transferPrice!.abs().toString()
                : 'Price not available',
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
