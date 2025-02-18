part of 'teamComp.dart';

extension TabOrders on TeamComp {
  Widget getOrdersWidget(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];

              Color? colorBackground;
              PlayerWithPosition playerOutMap;
              Player playerOut;
              Widget playerOutWidget;

              if (playersWithPosition.any(
                  (PlayerWithPosition playerWithPosition) =>
                      playerWithPosition.id == sub.idPlayerOut)) {
                playerOutMap = playersWithPosition.firstWhere(
                    (PlayerWithPosition playerWithPosition) =>
                        playerWithPosition.id == sub.idPlayerOut);
                // playerOut = Player.fromMap(playerOutMap);
                playerOut = playerOutMap.player!;
                playerOutWidget = Row(
                  children: [
                    Transform.rotate(
                      angle: pi,
                      child: Icon(
                        Icons.directions_rounded,
                        color: Colors.red,
                      ),
                    ),
                    playerOut.getPlayerNameToolTip(context),
                  ],
                );
              } else {
                playerOutWidget = Text('Out: Player not found');
              }

              PlayerWithPosition playerInMap;
              Player? playerIn;
              Widget playerInWidget;

              if (playersWithPosition
                  .any((player) => player.id == sub.idPlayerIn)) {
                playerInMap = playersWithPosition.firstWhere(
                    (playerWithPosition) =>
                        playerWithPosition.id == sub.idPlayerIn);
                // playerIn = Player.fromMap(playerInMap);
                playerIn = playerInMap.player;
                playerInWidget = Row(
                  children: [
                    Icon(
                      Icons.directions_rounded,
                      color: Colors.green,
                    ),
                    playerIn!.getPlayerNameToolTip(context),
                  ],
                );
              } else {
                playerInWidget = Text('Out: Player not found');
              }

              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      12), // Adjust border radius as needed
                  side: const BorderSide(
                    color: Colors.blueGrey, // Border color
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.multiple_stop),
                            Text('Substitution'),
                          ],
                        ),
                        Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              shape: BoxShape.circle,
                            ),
                            child: sub.minute == null
                                ? Icon(Icons.all_inclusive)
                                : Text('${sub.minute}\'',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)))
                      ],
                    ),
                    Column(
                      children: [
                        playerInWidget,
                        playerOutWidget,
                      ],
                    ),
                  ],
                ),
                subtitle: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Text(
                        //   playerOutMap.name,
                        //   style: TextStyle(
                        //       fontStyle: FontStyle.italic,
                        //       color: Colors.blueGrey),
                        // ),
                        Row(
                          children: [
                            Icon(Icons.filter_alt),
                            Text('Condition: '),
                            if (sub.condition == null) Text('Always'),
                            if (sub.condition != null && sub.condition! > 0)
                              Row(
                                children: [
                                  Text('Winning by '),
                                  Text(
                                    '+${sub.condition}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ],
                              ),
                            if (sub.condition != null && sub.condition! < 0)
                              Row(
                                children: [
                                  Text('Losing by '),
                                  Text(
                                    '-${sub.condition}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            if (sub.condition != null && sub.condition == 0)
                              Text('Draw'),
                          ],
                        ),
                      ],
                    ),
                    if (sub.error != null)
                      Row(
                        children: [
                          Icon(Icons.error),
                          Text(sub.error!),
                        ],
                      ),
                  ],
                ),
                trailing: isPlayed
                    ? sub.minuteReal != null
                        ? Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Text('${sub.minuteReal}\''),
                          )
                        : Icon(
                            Icons.cancel,
                            color: Colors.red,
                          )
                    : IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          /// Update the game order table by resetting column to NULL
                          // if (await deleteFromDB(
                          //       context: context,
                          //       tableName: 'game_orders',
                          //       data: {
                          //         'id': sub.id,
                          //       },
                          //     ) ==
                          //     true) {
                          bool isOK = await operationInDB(
                              context, 'DELETE', 'game_orders',
                              matchCriteria: {
                                'id': sub.id,
                              });
                          if (isOK) {
                            context.showSnackBar(
                                'The order has been successfully deleted',
                                icon: Icon(iconSuccessfulOperation,
                                    color: Colors.green));
                          }
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
