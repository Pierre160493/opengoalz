import 'dart:math';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

class PlayerTransferBidDialogBox extends StatefulWidget {
  final Player player;
  PlayerTransferBidDialogBox({required this.player});
  @override
  _PlayerTransferBidDialogBoxState createState() =>
      _PlayerTransferBidDialogBoxState();
}

class _PlayerTransferBidDialogBoxState
    extends State<PlayerTransferBidDialogBox> {
  final TextEditingController _bidController = TextEditingController();
  bool _isValidBid = true;

  @override
  void initState() {
    super.initState();
    _bidController.addListener(_validateBid);
  }

  @override
  void dispose() {
    _bidController.removeListener(_validateBid);
    _bidController.dispose();
    super.dispose();
  }

  void _validateBid() {
    setState(() {
      final int? bidAmount = int.tryParse(_bidController.text);
      if (bidAmount == null) {
        _isValidBid = false;
        return;
      }

      final int availableCash =
          Provider.of<SessionProvider>(context, listen: false)
              .user!
              .selectedClub!
              .cash;
      final int? currentHighestBid = widget.player.transferBids.length == 1
          ? null
          : widget.player.transferBids.last.amount;
      final int minimumBid = currentHighestBid == null
          ? 1000
          : max(1000, (currentHighestBid * 1.01).ceil());

      _isValidBid = bidAmount <= availableCash && bidAmount >= minimumBid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int? currentHighestBid = widget.player.transferBids.length == 1
        ? null
        : widget.player.transferBids.last.amount;
    final int minimumBid = currentHighestBid == null
        ? 1000
        : max(1000, (currentHighestBid * 1.01).ceil());

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return AlertDialog(
        title: Row(
          children: [
            Text('Transfer Bid for '),
            widget.player.getPlayerNames(context),
          ],
        ),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              minWidth: min(constraints.maxWidth * 0.8, maxWidth * 0.8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Provider.of<SessionProvider>(context)
                    .user!
                    .selectedClub!
                    .getCashListTile(),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.green, width: 2.0),
                  ),
                  leading: Icon(
                    Icons.gavel,
                    color: Colors.green,
                  ),
                  title: Text(currentHighestBid == null
                      ? 'No bids yet'
                      : 'Current highest bid: $currentHighestBid'),
                  subtitle: currentHighestBid == null
                      ? null
                      : Text('By: ${widget.player.transferBids.last.nameClub}'),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  leading: Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                  title: TextFormField(
                    controller: _bidController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter your bid amount',
                      border: OutlineInputBorder(),
                      errorText: _isValidBid ? null : 'Invalid bid amount',
                    ),
                  ),
                  subtitle: Tooltip(
                    message: 'Click to bid the minimum amount',
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _bidController.text = minimumBid.toString();
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            'Minimum bid: $minimumBid',
                            style: styleItalicBlueGrey.copyWith(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
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

                  Navigator.of(context).pop();
                },
                child: Row(
                  children: [
                    Icon(Icons.person_search, color: Colors.green),
                    formSpacer3,
                    Text('Bid on '),
                    widget.player.getPlayerNames(context)
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
