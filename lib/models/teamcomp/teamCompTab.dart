import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/playerPosition.dart';
import 'package:opengoalz/models/teamcomp/teamComp.dart';
import 'package:opengoalz/models/teamcomp/teamCompPlayerCard.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TeamCompTab extends StatefulWidget {
  final TeamComp? teamcomp;

  const TeamCompTab({Key? key, required this.teamcomp}) : super(key: key);

  @override
  _TeamCompTabState createState() => _TeamCompTabState();
}

class _TeamCompTabState extends State<TeamCompTab> {
  @override
  Widget build(BuildContext context) {
    print('Size: ' + MediaQuery.of(context).size.width.toString());
    print('Size: ' + maxWidth.toString());
    double width =
        (min(MediaQuery.of(context).size.width, maxWidth) ~/ 6).toDouble();
    print('width: ' + width.toString());

    if (widget.teamcomp == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconBug, color: Colors.red, size: iconSizeLarge),
            formSpacer12,
            Text(
              'No teamcomp selected',
              style: TextStyle(
                color: Colors.red,
                fontSize: 24,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      );
    }
    TeamComp selectedTeamcomp = widget.teamcomp!;

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
            if (selectedTeamcomp.errors != null &&
                selectedTeamcomp.errors!.isNotEmpty)
              ListTile(
                shape: shapePersoRoundedBorder(Colors.red),
                // leading: Icon(iconBug, color: Colors.red, size: iconSizeMedium),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: selectedTeamcomp.errors!.map((error) {
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
              title: Text(selectedTeamcomp.name),
              leading: Icon(
                iconTeamComp,
                color: Colors.green,
                size: iconSizeMedium,
              ),
              subtitle: Text(selectedTeamcomp.description,
                  style: styleItalicBlueGrey),
              trailing: selectedTeamcomp.isPlayed
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
                                          await selectedTeamcomp
                                              .updatePlayerNotesToDefaultBasedOnPos(
                                                  context,
                                                  updateSmallNotes: true);
                                        },
                                        trailing: IconButton(
                                          tooltip: 'Update shirts numbers too',
                                          icon: Icon(iconShirt,
                                              color: Colors.orange),
                                          onPressed: () async {
                                            await selectedTeamcomp
                                                .updatePlayerNotesToDefaultBasedOnPos(
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
                                          await selectedTeamcomp
                                              .updatePlayerNotesToDefaultBasedOnPos(
                                                  context,
                                                  updateShirtNumber: true);
                                        },
                                        trailing: IconButton(
                                          tooltip: 'Update small notes too',
                                          icon: Icon(Icons.edit_note,
                                              color: Colors.orange),
                                          onPressed: () async {
                                            await selectedTeamcomp
                                                .updatePlayerNotesToDefaultBasedOnPos(
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
                                          await operationInDB(
                                            context,
                                            'FUNCTION',
                                            'teamcomp_copy_previous',
                                            data: {
                                              'inp_id_teamcomp':
                                                  selectedTeamcomp.id,
                                              'inp_season_number': -999
                                            },
                                            messageSuccess:
                                                'The teamcomp has successfully being cleaned',
                                          ); // Use index to modify id

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
                                            await operationInDB(
                                              context,
                                              'FUNCTION',
                                              'teamcomp_copy_previous',
                                              data: {
                                                'inp_id_teamcomp':
                                                    selectedTeamcomp.id,
                                                'inp_week_number': index + 1
                                              },
                                              messageSuccess:
                                                  'The teamcomp has successfully being applied',
                                            ); // Use index to modify id
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
                              child: persoCancelRow(),
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
                                await operationInDB(
                                    context, 'UPDATE', 'games_teamcomp',
                                    data: {
                                      'name': inputName,
                                      'description': inputDescription
                                    },
                                    matchCriteria: {'id': selectedTeamcomp.id},
                                    messageSuccess:
                                        'Successfully updated the teamcomp');

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
            _getStartingTeam(context, selectedTeamcomp, width),
            // Text('_getStartingTeam(context, width)'),
            formSpacer12, // Add spacing between rows
            _getSubstitutes(context, selectedTeamcomp, width)
            // Text('getSubstitutes(context, width)')
          ],
        ),
      ),
    );
  }

  Widget _getStartingTeam(
      BuildContext context, TeamComp selectedTeamcomp, double width) {
    return Stack(
      children: [
        Center(
          child: SvgPicture.asset(
            'assets/images/Football_field_half++.svg',
            width: 6 * width,
          ),
        ),
        Positioned(
          top: 0.05 * width, // 1/8th from the top
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: width),
              ...selectedTeamcomp.playersWithPosition
                  .where((PlayerWithPosition playerWithPosition) =>
                      playerWithPosition.type == 'Attack')
                  .map((PlayerWithPosition playerWithPosition) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: width / 12),
                        child: TeamCompPlayerCard(
                          context: context,
                          width: width,
                          playerWithPosition: playerWithPosition,
                          teamComp: selectedTeamcomp,
                        ),
                      ))
                  .toList(),
              SizedBox(width: width),
            ],
          ),
        ),
        Positioned(
          top: 1.5 * width, // 1/4th from the top
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: selectedTeamcomp.playersWithPosition
                .where((PlayerWithPosition playerWithPosition) =>
                    playerWithPosition.type == 'Midfield')
                .map((PlayerWithPosition playerWithPosition) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 12),
                      child: TeamCompPlayerCard(
                        context: context,
                        width: width,
                        playerWithPosition: playerWithPosition,
                        teamComp: selectedTeamcomp,
                      ),
                    ))
                .toList(),
          ),
        ),
        Positioned(
          top: 3 * width, // 2.5th from the top
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: selectedTeamcomp.playersWithPosition
                .where((PlayerWithPosition playerWithPosition) =>
                    playerWithPosition.type == 'Defense')
                .map((PlayerWithPosition playerWithPosition) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 12),
                      child: TeamCompPlayerCard(
                        context: context,
                        width: width,
                        playerWithPosition: playerWithPosition,
                        teamComp: selectedTeamcomp,
                      ),
                    ))
                .toList(),
          ),
        ),
        Positioned(
          top: 4.2 * width, // 1.5th from the top
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: selectedTeamcomp.playersWithPosition
                .where((PlayerWithPosition playerWithPosition) =>
                    playerWithPosition.type == 'Keeper')
                .map((PlayerWithPosition playerWithPosition) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: width / 12),
                      child: TeamCompPlayerCard(
                        context: context,
                        width: width,
                        playerWithPosition: playerWithPosition,
                        teamComp: selectedTeamcomp,
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _getSubstitutes(
      BuildContext context, TeamComp selectedTeamcomp, double width) {
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
            TeamCompPlayerCard(
                context: context,
                width: width,
                playerWithPosition:
                    selectedTeamcomp.getPlayerMapByName('Sub 1'),
                teamComp: selectedTeamcomp),
            TeamCompPlayerCard(
                context: context,
                width: width,
                playerWithPosition:
                    selectedTeamcomp.getPlayerMapByName('Sub 2'),
                teamComp: selectedTeamcomp),
            TeamCompPlayerCard(
                context: context,
                width: width,
                playerWithPosition:
                    selectedTeamcomp.getPlayerMapByName('Sub 3'),
                teamComp: selectedTeamcomp),
          ],
        ),
        const SizedBox(height: 16.0), // Add spacing between rows
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TeamCompPlayerCard(
                context: context,
                width: width,
                playerWithPosition:
                    selectedTeamcomp.getPlayerMapByName('Sub 4'),
                teamComp: selectedTeamcomp),
            TeamCompPlayerCard(
                context: context,
                width: width,
                playerWithPosition:
                    selectedTeamcomp.getPlayerMapByName('Sub 5'),
                teamComp: selectedTeamcomp),
            TeamCompPlayerCard(
                context: context,
                width: width,
                playerWithPosition:
                    selectedTeamcomp.getPlayerMapByName('Sub 6'),
                teamComp: selectedTeamcomp),
            TeamCompPlayerCard(
                context: context,
                width: width,
                playerWithPosition:
                    selectedTeamcomp.getPlayerMapByName('Sub 7'),
                teamComp: selectedTeamcomp),
          ],
        ),
      ],
    );
  }
}
