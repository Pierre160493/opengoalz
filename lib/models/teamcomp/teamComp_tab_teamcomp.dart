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
            /// Display errors if any
            if (errors != null && errors!.isNotEmpty)
              ListTile(
                shape: shapePersoRoundedBorder(Colors.red),
                // leading: Icon(iconBug, color: Colors.red, size: iconSizeMedium),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: errors!.map((error) {
                    return ListTile(
                      leading: Icon(iconBug, color: Colors.red),
                      title: Text(error),
                    );
                  }).toList(),
                ),
              ),

            /// If the game is not played yet, the user can clean the teamcomp or apply a default teamcomp
            ListTile(
              shape: shapePersoRoundedBorder(),
              title: Text(name),
              leading: Icon(
                iconTeamComp,
                color: Colors.green,
                size: iconSizeMedium,
              ),
              subtitle: Text(description, style: styleItalicBlueGrey),
              trailing: isPlayed
                  ? null
                  : Tooltip(
                      message: 'More teamcomps options',
                      child: IconButton(
                          icon: Icon(Icons.more_vert, color: Colors.green),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      /// Rewrite small notes for players based on position
                                      ListTile(
                                        leading: Icon(
                                          Icons.edit_note,
                                          color: Colors.orange,
                                          size: iconSizeMedium,
                                        ),
                                        shape: shapePersoRoundedBorder(
                                            Colors.orange),
                                        title: Text('Edit notes'),
                                        subtitle: Text(
                                            'Edit notes for players based on their position',
                                            style: styleItalicBlueGrey),
                                        onTap: () async {
                                          await updatePlayerNotesToDefaultBasedOnPos(
                                              context,
                                              updateSmallNotes: true);
                                        },
                                        trailing: IconButton(
                                          tooltip: 'Update shirts numbers too',
                                          icon: Icon(iconShirt,
                                              color: Colors.orange),
                                          onPressed: () async {
                                            await updatePlayerNotesToDefaultBasedOnPos(
                                                context,
                                                updateSmallNotes: true,
                                                updateShirtNumber: true);
                                          },
                                        ),
                                      ),

                                      /// Rewrite small notes for players based on position
                                      ListTile(
                                        leading: Icon(
                                          iconShirt,
                                          color: Colors.orange,
                                          size: iconSizeMedium,
                                        ),
                                        shape: shapePersoRoundedBorder(
                                            Colors.orange),
                                        title: Text('Update shirt number'),
                                        subtitle: Text(
                                            'Update shirt number for players based on their position',
                                            style: styleItalicBlueGrey),
                                        onTap: () async {
                                          await updatePlayerNotesToDefaultBasedOnPos(
                                              context,
                                              updateShirtNumber: true);
                                        },
                                        trailing: IconButton(
                                          tooltip: 'Update small notes too',
                                          icon: Icon(Icons.edit_note,
                                              color: Colors.orange),
                                          onPressed: () async {
                                            await updatePlayerNotesToDefaultBasedOnPos(
                                                context,
                                                updateSmallNotes: true,
                                                updateShirtNumber: true);
                                          },
                                        ),
                                      ),

                                      /// Remove all players from the teamcomp
                                      ListTile(
                                        leading: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        shape:
                                            shapePersoRoundedBorder(Colors.red),
                                        title: Text('Remove all'),
                                        subtitle: Text(
                                            'Remove all players from the teamcomp',
                                            style: styleItalicBlueGrey),
                                        onTap: () async {
                                          bool confirm = await context
                                              .showConfirmationDialog(
                                                  'Are you sure you want to remove all players from the teamcomp?');

                                          if (!confirm) return;
                                          bool isOK = await operationInDB(
                                              context,
                                              'FUNCTION',
                                              'teamcomp_copy_previous',
                                              data: {
                                                'inp_id_teamcomp': id,
                                                'inp_season_number': -999
                                              }); // Use index to modify id
                                          if (isOK) {
                                            context.showSnackBar(
                                                'The teamcomp has successfully being cleaned',
                                                icon: Icon(
                                                    iconSuccessfulOperation,
                                                    color: Colors.green));
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),

                                      ...List.generate(7, (index) {
                                        return ListTile(
                                          leading: Icon(Icons.save),
                                          shape: shapePersoRoundedBorder(),
                                          title: Text(
                                              'Apply default ${index + 1} teamcomp'),
                                          subtitle: Text(
                                              'Apply the default ${index + 1} teamcomp to this teamcomp',
                                              style: styleItalicBlueGrey),
                                          onTap: () async {
                                            bool confirm = await context
                                                .showConfirmationDialog(
                                                    'Are you sure you want to apply the default ${index + 1} teamcomp to this teamcomp ?');

                                            if (!confirm) return;
                                            bool isOK = await operationInDB(
                                                context,
                                                'FUNCTION',
                                                'teamcomp_copy_previous',
                                                data: {
                                                  'inp_id_teamcomp': id,
                                                  'inp_week_number': index + 1
                                                }); // Use index to modify id
                                            if (isOK) {
                                              context.showSnackBar(
                                                  'The teamcomp has successfully being applied',
                                                  icon: Icon(
                                                      iconSuccessfulOperation,
                                                      color: Colors.green));
                                            }
                                            Navigator.pop(context);
                                          },
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              },
                            );
                          }),
                    ),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String inputName = '';
                    String inputDescription = '';
                    return AlertDialog(
                      title: const Text('Change Teamcomp'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (valueName) {
                                inputName = valueName;
                              },
                              decoration: const InputDecoration(
                                  hintText: "Enter the new name"),
                            ),
                            TextField(
                              onChanged: (valueDescription) {
                                inputDescription = valueDescription;
                              },
                              decoration: const InputDecoration(
                                  hintText: "Enter the new description"),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: persoCancelRow,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Row(
                                children: [
                                  Icon(iconSuccessfulOperation,
                                      color: Colors.green),
                                  formSpacer3,
                                  const Text('Submit'),
                                ],
                              ),
                              onPressed: () async {
                                bool isOK = await operationInDB(
                                    context, 'UPDATE', 'games_teamcomp', data: {
                                  'name': inputName,
                                  'description': inputDescription
                                }, matchCriteria: {
                                  'id': id
                                });

                                if (isOK) {
                                  context.showSnackBarSuccess(
                                      'Successfully updated the teamcomp');
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                }
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
              // trailing: IconButton(iconDetails),
            ),
            formSpacer12, // Add spacing between rows
            _getStartingTeam(context, width),
            formSpacer12, // Add spacing between rows
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
