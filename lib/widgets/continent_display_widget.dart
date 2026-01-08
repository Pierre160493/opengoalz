import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/continent_page.dart';

class ContinentRowWidget extends StatelessWidget {
  final String? continentName;
  final int? idMultiverse;

  const ContinentRowWidget({
    Key? key,
    required this.continentName,
    required this.idMultiverse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.public, size: iconSizeSmall, color: Colors.green),
        formSpacer3,
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // Remove default padding if not desired
            minimumSize: Size.zero, // Remove default minimum size
            tapTargetSize:
                MaterialTapTargetSize.shrinkWrap, // Reduce tap target size
            alignment: Alignment.centerLeft, // Align text to the left
          ),
          onPressed: continentName == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    ContinentPage.route(continentName!,
                        idMultiverse: idMultiverse),
                  );
                },
          child: Text(
            continentName ?? 'International',
            style: styleItalicBlueGrey.copyWith(fontSize: fontSizeSmall),
          ),
        ),
      ],
    );
  }
}
