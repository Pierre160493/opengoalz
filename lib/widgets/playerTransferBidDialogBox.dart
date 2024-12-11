import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/models/club/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/postgresql_requests.dart';
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
  // bool _isBidValid = true;
  int _minBidAbsolute = 100;
  int? _bidAmount;

  @override
  void initState() {
    super.initState();
    _bidController.addListener(_validateBid);
    _validateBid();
  }

  @override
  void dispose() {
    _bidController.removeListener(_validateBid);
    _bidController.dispose();
    super.dispose();
  }

  void _validateBid() {
    setState(() {
      _bidAmount = int.tryParse(_bidController.text);
      if (_bidAmount == null) {
        // _isBidValid = false;
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
          ? _minBidAbsolute
          : max(_minBidAbsolute, (currentHighestBid * 1.01).ceil());

      if (_bidAmount! > availableCash) {
        // context.showSnackBarError(
        //     'Successfully placed bid on ${widget.player.getPlayerNames(context)}');
        _bidAmount = null;
      } else if (_bidAmount! < minimumBid) {
        _bidAmount = null;
      } else if (_bidAmount! < currentHighestBid!) {
        _bidAmount = null;
      }

      // _isBidValid = _bidAmount <= availableCash && _bidAmount >= minimumBid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int? currentHighestBid = widget.player.idClub == null
        ? widget.player.transferBids.length == 0
            ? null
            : widget.player.transferBids.last.amount
        : widget.player.transferBids.length == 1
            ? null
            : widget.player.transferBids.last.amount;
    final int minimumBid = currentHighestBid == null
        ? _minBidAbsolute
        : max(_minBidAbsolute, (currentHighestBid * 1.01).ceil());

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
                Provider.of<SessionProvider>(context, listen: false)
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
                  title: Row(
                    children: [
                      Text(currentHighestBid == null
                          ? 'No bids yet'
                          : 'Current highest bid: '),
                      if (currentHighestBid != null)
                        Text(
                            NumberFormat('#,###')
                                .format(currentHighestBid)
                                .replaceAll(',', ' '),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  subtitle: currentHighestBid == null
                      ? null
                      : Text('By: ${widget.player.transferBids.last.nameClub}'),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                        color: _bidAmount == null ? Colors.red : Colors.green,
                        width: 2.0),
                  ),
                  leading: Icon(
                    Icons.attach_money,
                    color: Colors.blue,
                  ),
                  title: TextFormField(
                    controller: _bidController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter your bid amount',
                      border: OutlineInputBorder(),
                      errorText:
                          _bidAmount == null ? 'Invalid bid amount' : null,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Minimum bid: ',
                                style: styleItalicBlueGrey.copyWith(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                NumberFormat('#,###')
                                    .format(minimumBid)
                                    .replaceAll(',', ' '),
                                style: styleItalicBlueGrey.copyWith(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
              if (_bidAmount != null)
                TextButton(
                  onPressed: () async {
                    print({
                      'inp_id_player': widget.player.id,
                      'inp_id_club_bidder':
                          Provider.of<SessionProvider>(context, listen: false)
                              .user!
                              .selectedClub!
                              .id,
                      'inp_amount': int.parse(_bidController.text)
                    });

                    /// Try to insert the bid
                    bool isOK = await operationInDB(
                        context, 'FUNCTION', 'transfers_handle_new_bid',
                        data: {
                          'inp_id_player': widget.player.id,
                          'inp_id_club_bidder': Provider.of<SessionProvider>(
                                  context,
                                  listen: false)
                              .user!
                              .selectedClub!
                              .id,
                          'inp_amount': int.parse(_bidController.text)
                        }); // Use index to modify id
                    if (isOK) {
                      context.showSnackBar(
                          'Successfully placed bid on ${widget.player.getPlayerNames(context)}',
                          icon: Icon(iconSuccessfulOperation,
                              color: Colors.green));
                    }

                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.gavel, color: Colors.green),
                      formSpacer3,
                      // Text('Bid ${int.parse(_bidController.text)} on '),
                      Text('Bid '),
                      Text(
                        NumberFormat('#,###')
                            .format(_bidAmount)
                            .replaceAll(',', ' '),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(' on '),
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
