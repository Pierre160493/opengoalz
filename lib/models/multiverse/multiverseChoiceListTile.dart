import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/multiverse/multiverse.dart';
import 'package:opengoalz/pages/multiverse_page.dart';

class MultiverseChoiceListTile extends StatelessWidget {
  final Multiverse? selectedMultiverse;
  final ValueChanged<Multiverse?> onMultiverseSelected;
  final VoidCallback onMultiverseReset;

  MultiverseChoiceListTile({
    required this.selectedMultiverse,
    required this.onMultiverseSelected,
    required this.onMultiverseReset,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        iconMultiverseSpeed,
        size: iconSizeMedium,
        color: selectedMultiverse == null ? Colors.red : Colors.green,
      ),
      shape: shapePersoRoundedBorder(
          selectedMultiverse == null ? Colors.red : Colors.green),
      title: Text(
          selectedMultiverse == null
              ? 'Select Multiverse'
              : selectedMultiverse!.name,
          style:
              TextStyle(fontSize: fontSizeMedium, fontWeight: FontWeight.bold)),
      subtitle: selectedMultiverse == null
          ? null
          : Text('Selected multiverse',
              style: styleItalicBlueGrey.copyWith(fontSize: fontSizeSmall)),
      trailing: selectedMultiverse == null
          ? null
          : IconButton(
              tooltip: 'Reset the selected multiverse',
              onPressed: onMultiverseReset,
              icon: Icon(Icons.delete_forever,
                  size: iconSizeMedium, color: Colors.red),
            ),
      onTap: () async {
        final multiverse = await Navigator.push<Multiverse>(
          context,
          MultiversePage.route(
            null,
            isReturningMultiverse: true,
          ),
        );
        onMultiverseSelected(multiverse);
      },
    );
  }
}
