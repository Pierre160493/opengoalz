import 'package:flutter/material.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/models/mails/mail.dart';

Future<bool> updateMails(
  BuildContext context,
  List<Mail> mails, {
  required Map<String, dynamic> data,
}) async {
  return await operationInDB(
    context,
    'UPDATE',
    'mails',
    data: data,
    inFilterMatchCriteria: {'id': mails.map((mail) => mail.id).toList()},
  );
}
