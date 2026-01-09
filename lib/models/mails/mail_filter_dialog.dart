import 'package:flutter/material.dart';
import 'package:opengoalz/models/mails/mail.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/utils/mail_operations.dart';

Future<void> showMailFilterDialog(
    BuildContext context, List<Mail> mails, Function setState) async {
  bool _filterGameResult = true;
  bool _filterTransferInfo = true;
  bool _filterSeasonInfo = true;
  bool _filterClubInfo = true;

  List<Mail> mailsGameResult =
      mails.where((mail) => mail.isGameResult).toList();
  int mailsGameResultLength = mailsGameResult.length;
  List<Mail> mailsTransferInfo =
      mails.where((mail) => mail.isTransferInfo).toList();
  int mailsTransferInfoLength = mailsTransferInfo.length;
  List<Mail> mailsSeasonInfo =
      mails.where((mail) => mail.isSeasonInfo).toList();
  int mailsSeasonInfoLength = mailsSeasonInfo.length;
  List<Mail> mailsClubInfo = mails.where((mail) => mail.isClubInfo).toList();
  int mailsClubInfoLength = mailsClubInfo.length;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Filter Mails', style: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.bold)),
            content: Container(
              width: maxWidth * 0.8, // Set the desired width here
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Game Result Mails
                  ListTile(
                    leading: Icon(Icons.sports_soccer,
                        color: _filterGameResult ? Colors.green : Colors.red),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              mailsGameResultLength.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _filterGameResult
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: fontSizeMedium,
                              ),
                            ),
                            formSpacer6,
                            Text('Game Result', style: TextStyle(fontSize: fontSizeMedium)),
                          ],
                        ),
                        Checkbox(
                          value: _filterGameResult,
                          onChanged: (value) {
                            setState(() {
                              _filterGameResult = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    shape: shapePersoRoundedBorder(),
                    trailing: IconButton(
                      tooltip: 'Delete these mails',
                      onPressed: mailsGameResultLength == 0
                          ? null
                          : () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text(mailsGameResultLength == 1
                                        ? 'Are you sure you want to delete the Game Result mail ?'
                                        : 'Are you sure you want to delete the ${mailsGameResultLength} Game Result mails ?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: persoCancelRow()),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: persoValidRow('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (!confirm) return;
                              Map<String, dynamic> data = {
                                'date_delete': DateTime.now()
                                    .add(Duration(days: 7))
                                    .toIso8601String()
                              };
                              bool isOk = await updateMails(
                                  context, mailsGameResult,
                                  data: data);
                              if (isOk) {
                                setState(() {
                                  mailsGameResult.forEach((mail) {
                                    mail.dateDelete =
                                        DateTime.now().add(Duration(days: 7));
                                  });
                                });
                              }
                              Navigator.of(context).pop();
                            },
                      icon: Icon(iconMailDelete,
                          color: mailsGameResultLength == 0
                              ? Colors.grey
                              : Colors.red),
                    ),
                  ),

                  /// Transfer Info Mails
                  ListTile(
                    leading: Icon(iconTransfers,
                        color: _filterTransferInfo ? Colors.green : Colors.red),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              mailsTransferInfoLength.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _filterTransferInfo
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: fontSizeMedium,
                              ),
                            ),
                            formSpacer6,
                            Text('Transfer Info', style: TextStyle(fontSize: fontSizeMedium)),
                          ],
                        ),
                        Checkbox(
                          value: _filterTransferInfo,
                          onChanged: (value) {
                            setState(() {
                              _filterTransferInfo = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    shape: shapePersoRoundedBorder(),
                    trailing: IconButton(
                      tooltip: 'Delete these mails',
                      onPressed: mailsTransferInfoLength == 0
                          ? null
                          : () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text(mailsTransferInfoLength == 1
                                        ? 'Are you sure you want to delete the Transfer Info mail ?'
                                        : 'Are you sure you want to delete the ${mailsTransferInfoLength} Transfer Info mails ?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: persoCancelRow()),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: persoValidRow('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (!confirm) return;
                              Map<String, dynamic> data = {
                                'date_delete': DateTime.now()
                                    .add(Duration(days: 7))
                                    .toIso8601String()
                              };
                              bool isOk = await updateMails(
                                  context, mailsTransferInfo,
                                  data: data);
                              if (isOk) {
                                setState(() {
                                  mailsTransferInfo.forEach((mail) {
                                    mail.dateDelete =
                                        DateTime.now().add(Duration(days: 7));
                                  });
                                });
                              }
                              Navigator.of(context).pop();
                            },
                      icon: Icon(iconMailDelete,
                          color: mailsTransferInfoLength == 0
                              ? Colors.grey
                              : Colors.red),
                    ),
                  ),

                  /// Season Info Mails
                  ListTile(
                    leading: Icon(iconDetails,
                        color: _filterSeasonInfo ? Colors.green : Colors.red),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              mailsSeasonInfoLength.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _filterSeasonInfo
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: fontSizeMedium,
                              ),
                            ),
                            formSpacer6,
                            Text('Season Info', style: TextStyle(fontSize: fontSizeMedium)),
                          ],
                        ),
                        Checkbox(
                          value: _filterSeasonInfo,
                          onChanged: (value) {
                            setState(() {
                              _filterSeasonInfo = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    shape: shapePersoRoundedBorder(),
                    trailing: IconButton(
                      tooltip: 'Delete these mails',
                      onPressed: mailsSeasonInfoLength == 0
                          ? null
                          : () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text(mailsSeasonInfoLength == 1
                                        ? 'Are you sure you want to delete the Season Info mail ?'
                                        : 'Are you sure you want to delete the ${mailsSeasonInfoLength} Season Info mails ?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: persoCancelRow()),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: persoValidRow('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (!confirm) return;
                              Map<String, dynamic> data = {
                                'date_delete': DateTime.now()
                                    .add(Duration(days: 7))
                                    .toIso8601String()
                              };
                              bool isOk = await updateMails(
                                  context, mailsSeasonInfo,
                                  data: data);
                              if (isOk) {
                                setState(() {
                                  mailsSeasonInfo.forEach((mail) {
                                    mail.dateDelete =
                                        DateTime.now().add(Duration(days: 7));
                                  });
                                });
                              }
                              Navigator.of(context).pop();
                            },
                      icon: Icon(iconMailDelete,
                          color: mailsSeasonInfoLength == 0
                              ? Colors.grey
                              : Colors.red),
                    ),
                  ),

                  /// Club Info Mails
                  ListTile(
                    leading: Icon(iconClub,
                        color: _filterClubInfo ? Colors.green : Colors.red),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              mailsClubInfoLength.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    _filterClubInfo ? Colors.green : Colors.red,
                                fontSize: fontSizeMedium,
                              ),
                            ),
                            formSpacer6,
                            Text('Club Info', style: TextStyle(fontSize: fontSizeMedium)),
                          ],
                        ),
                        Checkbox(
                          value: _filterClubInfo,
                          onChanged: (value) {
                            setState(() {
                              _filterClubInfo = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    shape: shapePersoRoundedBorder(),
                    trailing: IconButton(
                      tooltip: 'Delete these mails',
                      onPressed: mailsClubInfoLength == 0
                          ? null
                          : () async {
                              bool confirm = await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Confirm Deletion'),
                                    content: Text(mailsClubInfoLength == 1
                                        ? 'Are you sure you want to delete the Club Info mail ?'
                                        : 'Are you sure you want to delete the ${mailsClubInfoLength} Club Info mails ?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: persoCancelRow()),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: persoValidRow('Yes'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (!confirm) return;
                              Map<String, dynamic> data = {
                                'date_delete': DateTime.now()
                                    .add(Duration(days: 7))
                                    .toIso8601String()
                              };
                              bool isOk = await updateMails(
                                  context, mailsClubInfo,
                                  data: data);
                              if (isOk) {
                                setState(() {
                                  mailsClubInfo.forEach((mail) {
                                    mail.dateDelete =
                                        DateTime.now().add(Duration(days: 7));
                                  });
                                });
                              }
                              Navigator.of(context).pop();
                            },
                      icon: Icon(iconMailDelete,
                          color: mailsClubInfoLength == 0
                              ? Colors.grey
                              : Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterGameResult = true;
                        _filterTransferInfo = true;
                        _filterSeasonInfo = true;
                        _filterClubInfo = true;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.done_all, color: Colors.green),
                        formSpacer3,
                        Text('Set all filters', style: TextStyle(fontSize: fontSizeMedium)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Icon(iconSuccessfulOperation, color: Colors.green),
                        formSpacer3,
                        Text('Apply', style: TextStyle(fontSize: fontSizeMedium)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}
