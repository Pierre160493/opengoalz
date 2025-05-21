import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:provider/provider.dart';

void sendMailDialog(BuildContext context, {int? idClub, String? username}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      TextEditingController titleController = TextEditingController();
      TextEditingController messageController = TextEditingController();
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Enter email title',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Enter your email content here',
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                context.showSnackBarError(
                  'The title cannot be empty',
                );
                return;
              }
              if (messageController.text.isEmpty) {
                bool confirmed = await context.showConfirmationDialog(
                    'Your message is empty, do you want to send it anyway?');
                if (!confirmed) {
                  return;
                }
              }

              bool isOk = await operationInDB(
                context,
                'INSERT',
                'mails',
                data: {
                  'id_club': idClub,
                  'title': titleController.text,
                  'message': messageController.text,
                  'username_to': username,
                  'username_from':
                      Provider.of<UserSessionProvider>(context, listen: false)
                          .user
                          .username,
                },
                messageSuccess: 'Mail sent',
              );

              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                Icon(Icons.send, color: Colors.green),
                formSpacer3,
                Text('Send'),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: persoCancelRow,
          ),
        ],
      );
    },
  );
}
