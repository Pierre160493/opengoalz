import 'package:flutter/material.dart';
import 'package:opengoalz/models/mails/mail.dart';
import 'package:opengoalz/models/mails/mail_widget.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/utils/mail_operations.dart';

class MailList extends StatelessWidget {
  final List<Mail> mails;
  final bool isTrash;

  const MailList({required this.mails, required this.isTrash});

  @override
  Widget build(BuildContext context) {
    if (mails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 100, color: Colors.blueGrey),
            Text(isTrash ? 'Your delete box is empty' : 'Your inbox is empty'),
          ],
        ),
      );
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Mark all as read
            widgetManageMails(context, mails, operationType: 'markRead'),
            // Mark all as unread
            widgetManageMails(context, mails, operationType: 'markUnread'),
            // Delete or Restore all
            widgetManageMails(context, mails,
                operationType: isTrash ? 'restore' : 'delete'),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: mails.length,
            itemBuilder: (context, index) {
              final mail = mails[index];
              return MailWidget(
                mail: mail,
                onStateChange: (Function callback) {
                  callback();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget widgetManageMails(
    BuildContext context,
    List<Mail> mails, {
    required String operationType,
  }) {
    final String textMessage;
    final String confirmationMessage;
    final String successMessage;
    final Map<String, dynamic>? data;
    final Icon icon;

    switch (operationType) {
      case 'markRead':
        textMessage = 'Mark all as read';
        confirmationMessage =
            'Are you sure you want to mark all mails as read ?';
        successMessage = 'All ${mails.length} mails have been set to read';
        icon = Icon(Icons.mark_email_read, color: Colors.green);
        data = {'is_read': true};
        break;
      case 'markUnread':
        textMessage = 'Mark all as unread';
        confirmationMessage =
            'Are you sure you want to mark all mails as unread ?';
        successMessage = 'All ${mails.length} mails have been set to unread';
        icon = Icon(Icons.markunread, color: Colors.green);
        data = {'is_read': false};
        break;
      case 'delete':
        textMessage = 'Delete all';
        confirmationMessage =
            'Are you sure you want to throw all mails in the thrash ?';
        successMessage = 'All ${mails.length} mails will be deleted in 7 days';
        icon = Icon(iconMailDelete, color: Colors.red);
        data = {
          'date_delete': DateTime.now().add(Duration(days: 7)).toIso8601String()
        };
        break;
      case 'restore':
        textMessage = 'Restore all';
        confirmationMessage =
            'Are you sure you want to restore all mails from the thrash ?';
        successMessage =
            'All ${mails.length} mails have been restored from the thrash';
        icon = Icon(Icons.restore_from_trash, color: Colors.green);
        data = {'date_delete': null};
        break;
      default:
        throw Exception('Invalid operation type: $operationType');
    }

    return InkWell(
      onTap: () async {
        bool? shouldUpdate =
            await context.showConfirmationDialog(confirmationMessage);

        if (shouldUpdate == true) {
          bool isOk = await updateMails(context, mails, data: data!);

          if (isOk) {
            context.showSnackBar(successMessage,
                icon: Icon(iconSuccessfulOperation, color: Colors.green));
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            icon,
            SizedBox(width: 3),
            Text(textMessage),
          ],
        ),
      ),
    );
  }
}
