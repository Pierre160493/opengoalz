import 'dart:math';

import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/mails_page.dart';

Widget mailToolTip(BuildContext context, Profile user) {
  int numberMailsUnRead = user.mails
          .where((mail) => mail.dateDelete == null && mail.isRead == false)
          .length +
      (user.selectedClub != null
          ? user.selectedClub!.mails
              .where((mail) => mail.dateDelete == null && mail.isRead == false)
              .length
          : 0);
  return Tooltip(
    message: 'Open Mails Page',
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MailsPage()),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(iconMails,
              size: iconSizeMedium,
              color: numberMailsUnRead == 0 ? Colors.green : Colors.orange),
          Positioned(
            top: -8, // Adjust the position as needed
            right: -4, // Adjust the position as needed
            child: Container(
              padding: EdgeInsets.all(4), // Adjust the padding as needed
              decoration: BoxDecoration(
                color: colorIsSelected, // Background color for the badge
                shape: BoxShape.circle,
              ),
              child: Text(
                '${min(99, numberMailsUnRead)}',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontSize: 12, // Adjust the font size as needed
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
