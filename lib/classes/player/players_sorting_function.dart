import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'class/player.dart';

class SortingOption {
  final String title;
  final IconData? iconMain;
  final Row rowLeft;
  final Row rowRight;
  final String variableName;

  SortingOption({
    required this.title,
    this.iconMain,
    required this.rowLeft,
    required this.rowRight,
    required this.variableName,
  });
}

int comparePlayers(Player a, Player b, String variableName) {
  try {
    final aValue = a.getPropertyValue(variableName);
    final bValue = b.getPropertyValue(variableName);
    if (aValue is Comparable && bValue is Comparable) {
      return aValue.compareTo(bValue);
    }
  } catch (error) {
    print('Error accessing property: $error');
  }
  return 0;
}

Widget buildToolTip(BuildContext context, Function setState,
    List<Player> players, SortingOption option, bool isAscending) {
  return Tooltip(
    message: isAscending ? 'From min to max' : 'From max to min',
    child: InkWell(
      child: Row(
        children: [
          Text(isAscending ? 'ASC ' : 'DESC '),
          isAscending ? option.rowLeft : option.rowRight,
          Transform.rotate(
            angle: 3.14159 / 2, // π/2 radians
            child: Icon(Icons.arrow_outward, color: Colors.green),
          ),
          isAscending ? option.rowRight : option.rowLeft,
        ],
      ),
      onTap: () {
        setState(() {
          players.sort((a, b) => isAscending
              ? comparePlayers(a, b, option.variableName)
              : comparePlayers(b, a, option.variableName));
        });
        Navigator.pop(context);
      },
    ),
  );
}

void showSortingOptions(
    BuildContext context, Function setState, List<Player> players) {
  final List<SortingOption> sortingOptions = [
    SortingOption(
      title: 'Age',
      // hint: 'Order by birth date',
      iconMain: iconAge,
      rowLeft: Row(children: [Icon(Icons.child_friendly)]),
      rowRight: Row(children: [Icon(Icons.elderly)]),
      variableName: 'dateBirth',
    ),
    SortingOption(
      title: 'Surname',
      iconMain: Icons.sort_by_alpha_outlined,
      rowLeft: Row(
          children: [Text('A', style: TextStyle(fontWeight: FontWeight.bold))]),
      rowRight: Row(
          children: [Text('Z', style: TextStyle(fontWeight: FontWeight.bold))]),
      variableName: 'surName',
    ),
    SortingOption(
      title: 'Last Name',
      iconMain: Icons.sort_by_alpha_outlined,
      rowLeft: Row(
          children: [Text('A', style: TextStyle(fontWeight: FontWeight.bold))]),
      rowRight: Row(
          children: [Text('Z', style: TextStyle(fontWeight: FontWeight.bold))]),
      variableName: 'lastName',
    ),
    SortingOption(
      title: 'First Name',
      iconMain: Icons.sort_by_alpha_outlined,
      rowLeft: Row(
          children: [Text('A', style: TextStyle(fontWeight: FontWeight.bold))]),
      rowRight: Row(
          children: [Text('Z', style: TextStyle(fontWeight: FontWeight.bold))]),
      variableName: 'firstName',
    ),
    SortingOption(
      title: 'Shirt Number',
      iconMain: iconShirt,
      rowLeft: Row(children: [Icon(Icons.filter_1)]),
      rowRight: Row(children: [Icon(Icons.filter_9)]),
      variableName: 'shirtNumber',
    ),
    SortingOption(
      title: 'Expanses',
      iconMain: iconMoney,
      rowLeft: Row(
          children: [Text('1', style: TextStyle(fontWeight: FontWeight.bold))]),
      rowRight: Row(
          children: [Text('9', style: TextStyle(fontWeight: FontWeight.bold))]),
      variableName: 'expanses',
    ),
    SortingOption(
      title: 'Sell Date',
      iconMain: iconTransfers,
      rowLeft: Row(children: [Icon(Icons.date_range)]),
      rowRight: Row(children: [Icon(Icons.calendar_month)]),
      variableName: 'dateSell',
    ),
    SortingOption(
      title: 'Firing Date',
      iconMain: iconLeaveClub,
      rowLeft: Row(children: [Icon(Icons.date_range)]),
      rowRight: Row(children: [Icon(Icons.calendar_month)]),
      variableName: 'dateFiring',
    ),
    SortingOption(
      title: 'Injury End Date',
      iconMain: iconInjury,
      rowLeft: Row(children: [Icon(Icons.date_range)]),
      rowRight: Row(children: [Icon(Icons.calendar_month)]),
      variableName: 'dateEndInjury',
    ),
  ];

  showModalBottomSheet(
    // isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          ...sortingOptions.map((option) {
            return ListTile(
              title: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Tooltip(
                      message: 'Sort by ${option.title}',
                      child: InkWell(
                        onTap: () async {
                          Navigator.pop(context); // Close the bottom sheet
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title:
                                    Text('Sorting Players by ${option.title}'),
                                actions: [
                                  ListTile(
                                    title: buildToolTip(context, setState,
                                        players, option, true),
                                  ),
                                  ListTile(
                                    title: buildToolTip(context, setState,
                                        players, option, false),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            if (option.iconMain != null)
                              Row(
                                children: [
                                  Icon(
                                    option.iconMain,
                                    color: Colors.green,
                                  ),
                                  formSpacer6
                                ],
                              ),
                            Text(
                              option.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildToolTip(
                              context, setState, players, option, true),
                          buildToolTip(
                              context, setState, players, option, false),
                        ],
                      )),
                ],
              ),
            );
          }).toList(),
        ],
      );
    },
  );
}
