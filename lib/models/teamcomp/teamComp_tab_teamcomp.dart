part of 'teamComp.dart';

extension TeamCompTab on TeamComp {
  Widget getTeamCompWidget(BuildContext context) {
    double width =
        (min(MediaQuery.of(context).size.width, maxWidth) ~/ 6).toDouble();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.blueGrey,
          width: 1.0, // Set border width
        ),
      ),
      width: width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null)
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),

            /// Add a row of buttons to clean the teamcomp and apply the default teamcomp
            if (isPlayed == false)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Row(
                        children: [
                          Icon(Icons.layers_clear, color: Colors.red),
                        ],
                      ),
                      onPressed: () async {
                        bool confirm = await context.showConfirmationDialog(
                            'Are you sure you want to clean the teamcomp?');

                        if (!confirm) return;
                        bool isOK = await operationInDB(
                            context, 'FUNCTION', 'teamcomps_copy_previous',
                            data: {
                              'inp_id_teamcomp': id,
                              'inp_season_number': -999
                            }); // Use index to modify id
                        if (isOK) {
                          context.showSnackBar(
                              'The teamcomp has successfully being cleaned',
                              icon: Icon(iconSuccessfulOperation,
                                  color: Colors.green));
                        }
                      },
                    ),
                    ...List.generate(7, (index) {
                      return IconButton(
                        icon: Row(
                          children: [
                            Icon(Icons.save),
                            Text((index + 1).toString()),
                          ],
                        ),
                        onPressed: () async {
                          bool confirm = await context.showConfirmationDialog(
                              'Are you sure you want to apply the default ${index + 1} teamcomp to this teamcomp ?');

                          if (!confirm) return;
                          bool isOK = await operationInDB(
                              context, 'FUNCTION', 'teamcomps_copy_previous',
                              data: {
                                'inp_id_teamcomp': id,
                                'inp_week_number': index + 1
                              }); // Use index to modify id
                          if (isOK) {
                            context.showSnackBar(
                                'The teamcomp has successfully being applied',
                                icon: Icon(iconSuccessfulOperation,
                                    color: Colors.green));
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            // IconButton(
            //   icon: Icon(Icons.save),
            //   onPressed: () async {
            //     // final data = await supabase.rpc('teamcomps_copy_previous',
            //     //     params: {'inp_id_teamcomp': id});
            //     bool isOK = await operationInDB(
            //         context, 'FUNCTION', 'teamcomps_copy_previous',
            //         data: {'inp_id_teamcomp': id});
            //     if (isOK) {
            //       showSnackBar(
            //           context,
            //           'The teamcomp has successfully being applied',
            //           Icon(iconSuccessfulOperation, color: Colors.green));
            //     }
            //   },
            // ),
            const SizedBox(height: 12.0), // Add spacing between rows
            _getStartingTeam(context, width),
            const SizedBox(height: 12.0), // Add spacing between rows
            _getSubstitutes(context, width)
          ],
        ),
      ),
    );
  }

  Widget _getStartingTeam(BuildContext context, double width) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Striker')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Central Striker')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Striker')),
          ],
        ),
        const SizedBox(height: 6.0), // Add spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Winger')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Midfielder')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Central Midfielder')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Midfielder')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Winger')),
          ],
        ),
        const SizedBox(height: 6.0), // Add spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Back Winger')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Left Central Back')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Central Back')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Central Back')),
            SizedBox(width: width / 6),
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Right Back Winger')),
          ],
        ),
        const SizedBox(height: 6.0), // Add spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(
                context, width, getPlayerMapByName('Goal Keeper')),
          ],
        ),
      ],
    );
  }

  Widget _getSubstitutes(BuildContext context, double width) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text('Substitutes'),
                Icon(Icons.weekend, size: iconSizeLarge),
              ],
            ),
            SizedBox(width: 6.0),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 1')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 2')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 3')),
          ],
        ),
        const SizedBox(height: 16.0), // Add spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 4')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 5')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 6')),
            _playerTeamCompCard(context, width, getPlayerMapByName('Sub 7')),
          ],
        ),
      ],
    );
  }
}
