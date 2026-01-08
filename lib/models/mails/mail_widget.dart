import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/mails/mail.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/functions/stringParser.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/utils/mail_operations.dart';

class MailWidget extends StatelessWidget {
  final Mail mail;
  final Function onStateChange;

  const MailWidget({required this.mail, required this.onStateChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(8.0),
        color: mail.isRead ? Colors.grey[800] : null,
      ),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                /// Mark as read button
                IconButton(
                  tooltip: mail.isRead ? 'Mark as unread' : 'Mark as read',
                  icon: Icon(mail.isRead ? Icons.mark_email_read : Icons.mail,
                      color: Colors.green),
                  onPressed: () async {
                    Map<String, dynamic> data = {'is_read': !mail.isRead};
                    bool isOk = await updateMails(context, [mail], data: data);
                    if (isOk) {
                      onStateChange(() {
                        mail.isRead = !mail.isRead;
                      });
                    }
                  },
                ),
                Text('From', style: TextStyle(fontSize: fontSizeMedium)),
                formSpacer3,
                if (mail.userNameFrom == null)
                  Row(
                    children: [
                      Icon(iconStaff, color: Colors.green),
                      formSpacer3,
                      Text(mail.senderRole!,
                          style: TextStyle(fontSize: fontSizeMedium)),
                    ],
                  ),
              ],
            ),
            Row(
              children: [
                // Favorite button
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: mail.isFavorite ? Colors.red : Colors.blueGrey,
                  ),
                  onPressed: () async {
                    Map<String, dynamic> data = {
                      'is_favorite': !mail.isFavorite
                    };
                    bool isOk = await updateMails(context, [mail], data: data);
                    if (isOk) {
                      onStateChange(() {
                        mail.isFavorite = !mail.isFavorite;
                      });
                    }
                  },
                ),
                // Delete button
                if (mail.dateDelete == null)
                  IconButton(
                    icon: Icon(
                      iconMailDelete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      print('1: Delete mail ${mail.id}');
                      Map<String, dynamic> data = {
                        'date_delete': DateTime.now()
                            .add(Duration(days: 7))
                            .toIso8601String()
                      };
                      print('2: Delete mail ${mail.id}');
                      bool isOk =
                          await updateMails(context, [mail], data: data);
                      print('3: Delete mail ${mail.id}');
                      if (isOk) {
                        onStateChange(() {
                          mail.dateDelete =
                              DateTime.now().add(Duration(days: 7));
                        });
                        print('4: Delete mail ${mail.id}');
                      }
                    },
                  ),
                // Restore button
                if (mail.dateDelete != null)
                  IconButton(
                    icon: Icon(Icons.restore_from_trash, color: Colors.green),
                    onPressed: () async {
                      Map<String, dynamic> data = {'date_delete': null};
                      bool isOk =
                          await updateMails(context, [mail], data: data);
                      if (isOk) {
                        onStateChange(() {
                          mail.dateDelete = null;
                        });
                        context.showSnackBar(
                            'The mail has been moved back to your inbox',
                            icon: Icon(Icons.mark_email_read,
                                color: Colors.green));
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
        subtitle: Row(
          children: [
            _getMailIcon(mail),
            Expanded(
              child: Tooltip(
                message: mail.title,
                child: RichText(
                  text: stringParser(context, mail.title),
                ),
              ),
            ),
            formSpacer6,
            Icon(Icons.calendar_month, color: Colors.green),
            SizedBox(width: 3),
            Text(
              mail.createdAt.year == DateTime.now().year
                  ? DateFormat('MMM dd, kk:mm').format(mail.createdAt)
                  : DateFormat('MMM dd, yyyy, kk:mm').format(mail.createdAt),
              style: TextStyle(fontSize: fontSizeSmall),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: mail.message == null
                  ? Text('Empty message',
                      style: TextStyle(fontSize: fontSizeMedium))
                  : RichText(
                      text: stringParser(context, mail.message!),
                    ),
            ),
          ),
        ],
        onExpansionChanged: (isExpanded) async {
          if (isExpanded && !mail.isRead) {
            Map<String, dynamic> data = {'is_read': true};
            bool isOk = await updateMails(context, [mail], data: data);
            if (isOk) {
              onStateChange(() {
                mail.isRead = true;
              });
            }
          }
        },
      ),
    );
  }

  Icon _getMailIcon(Mail mail) {
    if (mail.isTransferInfo) return Icon(iconTransfers, color: Colors.green);
    if (mail.isGameResult)
      return Icon(Icons.sports_soccer, color: Colors.green);
    if (mail.isSeasonInfo) return Icon(iconDetails, color: Colors.green);
    if (mail.isClubInfo) return Icon(iconClub, color: Colors.green);
    return Icon(Icons.label_important, color: Colors.green);
  }
}
