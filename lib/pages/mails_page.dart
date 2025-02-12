import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/mail.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/functions/stringParser.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';

class MailsPage extends StatefulWidget {
  const MailsPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => MailsPage(),
    );
  }

  @override
  State<MailsPage> createState() => _MailsPageState();
}

class _MailsPageState extends State<MailsPage> {
  bool _filterGameResult = true;
  bool _filterTransferInfo = true;
  bool _filterSeasonInfo = true;
  bool _filterClubInfo = true;

  @override
  void initState() {
    super.initState();
  }

  bool _areAllFiltersTrue() {
    return _filterGameResult &&
        _filterTransferInfo &&
        _filterSeasonInfo &&
        _filterClubInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionProvider>(
      builder: (context, UserSessionProvider, child) {
        Club club = UserSessionProvider.user.selectedClub!;
        final List<Mail> mailsAll =
            club.mails.where((mail) => mail.dateDelete == null).toList();

        final mailsFiltered = _applyFilters(mailsAll);

        final mailsThrashFiltered = _applyFilters(UserSessionProvider
            .user.selectedClub!.mails
            .where((mail) => mail.dateDelete != null)
            .toList());

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                club.getClubNameClickable(context),
                Text(' Mails (${mailsAll.length})'),
              ],
            ),
            leading: goBackIconButton(context),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: _areAllFiltersTrue() ? Colors.green : Colors.orange,
                ),
                onPressed: () async {
                  await _showFilterDialog(context, mailsAll);
                  setState(() {});
                },
              ),
            ],
          ),
          body: MaxWidthContainer(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      buildTabWithIcon(
                          icon: Icons.inbox,
                          text: 'Inbox (${mailsFiltered.length})'),
                      buildTabWithIcon(
                          icon: Icons.auto_delete,
                          text: 'Thrash (${mailsThrashFiltered.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildInbox(context, mailsFiltered),
                        _buildThrash(context, mailsThrashFiltered),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFilterDialog(BuildContext context, List<Mail> mails) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Mails'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(Icons.sports_soccer,
                            color:
                                _filterGameResult ? Colors.green : Colors.red),
                        formSpacer3,
                        Text(
                            'Game Result (${mails.where((mail) => mail.isGameResult).length})'),
                      ],
                    ),
                    value: _filterGameResult,
                    onChanged: (value) {
                      setState(() {
                        _filterGameResult = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(iconTransfers,
                            color: _filterTransferInfo
                                ? Colors.green
                                : Colors.red),
                        formSpacer3,
                        Text(
                            'Transfer Info (${mails.where((mail) => mail.isTransferInfo).length})'),
                      ],
                    ),
                    value: _filterTransferInfo,
                    onChanged: (value) {
                      setState(() {
                        _filterTransferInfo = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(iconDetails,
                            color:
                                _filterSeasonInfo ? Colors.green : Colors.red),
                        formSpacer3,
                        Text(
                            'Season Info (${mails.where((mail) => mail.isSeasonInfo).length})'),
                      ],
                    ),
                    value: _filterSeasonInfo,
                    onChanged: (value) {
                      setState(() {
                        _filterSeasonInfo = value!;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(iconClub,
                            color: _filterClubInfo ? Colors.green : Colors.red),
                        formSpacer3,
                        Text(
                            'Club Info (${mails.where((mail) => mail.isClubInfo).length})'),
                      ],
                    ),
                    value: _filterClubInfo,
                    onChanged: (value) {
                      setState(() {
                        _filterClubInfo = value!;
                      });
                    },
                  ),
                ],
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
                          Text('Set all filters'),
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
                          Text('Apply'),
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

  List<Mail> _applyFilters(List<Mail> mails) {
    if (_areAllFiltersTrue()) return mails;
    return mails.where((mail) {
      if (_filterGameResult && mail.isGameResult) return true;
      if (_filterTransferInfo && mail.isTransferInfo) return true;
      if (_filterSeasonInfo && mail.isSeasonInfo) return true;
      if (_filterClubInfo && mail.isClubInfo) return true;
      return false;
    }).toList();
  }

  Widget _buildInbox(BuildContext context, List<Mail> mails) {
    if (mails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 100, color: Colors.blueGrey),
            Text('Your inbox is empty'),
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
            // Delete all
            widgetManageMails(context, mails, operationType: 'delete'),
          ],
        ),
        // Expanded widget to make _buildMailsList take the remaining space
        Expanded(
          child: _buildMailsList(mails),
        ),
      ],
    );
  }

  Widget _buildThrash(BuildContext context, List<Mail> mails) {
    if (mails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 100, color: Colors.blueGrey),
            Text('Your delete box is empty'),
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
            // Restore all
            widgetManageMails(context, mails, operationType: 'restore'),
          ],
        ),
        // Expanded widget to make _buildMailsList take the remaining space
        Expanded(
          child: _buildMailsList(mails),
        ),
      ],
    );
  }

  Widget _buildMailsList(List<Mail> mails) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isNarrow =
            constraints.maxWidth < maxWidth; // Adjust the threshold as needed

        return ListView.builder(
          itemCount: mails.length,
          itemBuilder: (context, index) {
            final mail = mails[index];
            return Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(8.0),
                color: mail.isRead
                    ? Colors.grey[800]
                    : null, // Background color based on read status
              ),
              child: ExpansionTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: mail.isRead
                              ? Icon(Icons.mark_email_read)
                              : Icon(Icons.mail),
                          onPressed: () async {
                            if (mail.isRead) {
                              await operationInDB(context, 'UPDATE', 'mails',
                                  data: {
                                    'is_read': false
                                  },
                                  matchCriteria: {
                                    'id': mail.id,
                                  });
                              setState(() {
                                mail.isRead = false;
                              });
                            } else {
                              await operationInDB(context, 'UPDATE', 'mails',
                                  data: {
                                    'is_read': true
                                  },
                                  matchCriteria: {
                                    'id': mail.id,
                                  });
                              setState(() {
                                mail.isRead = true;
                              });
                            }
                          },
                        ),
                        Text('From:'),
                        formSpacer3,
                        if (mail.userNameFrom != null)
                          getUserNameClickable(context,
                              userName: mail.userNameFrom),
                        if (mail.userNameFrom == null)
                          Row(
                            children: [
                              Icon(iconStaff),
                              formSpacer3,
                              Text(mail.senderRole!),
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
                            color:
                                mail.isFavorite ? Colors.red : Colors.blueGrey,
                          ),
                          onPressed: () async {
                            if (mail.isFavorite) {
                              await operationInDB(context, 'UPDATE', 'mails',
                                  data: {
                                    'is_favorite': false,
                                  },
                                  matchCriteria: {
                                    'id': mail.id,
                                  });
                              setState(() {
                                mail.isFavorite = false;
                              });
                            } else {
                              await operationInDB(context, 'UPDATE', 'mails',
                                  data: {
                                    'is_favorite': true,
                                  },
                                  matchCriteria: {
                                    'id': mail.id,
                                  });
                              setState(() {
                                mail.isFavorite = true;
                              });
                            }
                          },
                        ),
                        // Delete button
                        if (mail.dateDelete == null)
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              print('Delete button pressed');
                              await operationInDB(context, 'UPDATE', 'mails',
                                  data: {
                                    'date_delete': DateTime.now()
                                        .add(Duration(days: 7))
                                        .toIso8601String(),
                                  },
                                  matchCriteria: {
                                    'id': mail.id,
                                  });
                              // Manually update the mail object
                              setState(() {
                                mail.dateDelete =
                                    DateTime.now().add(Duration(days: 7));
                              });
                            },
                          ),
                        // Restore button
                        if (mail.dateDelete != null)
                          IconButton(
                            icon: Icon(Icons.restore_from_trash),
                            onPressed: () async {
                              bool isOk = await operationInDB(
                                  context, 'UPDATE', 'mails',
                                  data: {
                                    'date_delete': null,
                                  },
                                  matchCriteria: {
                                    'id': mail.id,
                                  });
                              if (isOk) {
                                setState(() {
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
                        // child: Text(
                        //   mail.title,
                        //   style: TextStyle(
                        //     fontStyle: FontStyle.italic,
                        //     fontWeight: FontWeight.bold,
                        //     // color: Colors.blueGrey
                        //   ),
                        //   overflow: TextOverflow.ellipsis,
                        //   maxLines: 1,
                        // ),
                        child: RichText(
                          text: stringParser(context, mail.title),
                        ),
                      ),
                    ),
                    formSpacer6,
                    Icon(Icons.calendar_month),
                    SizedBox(width: 3),
                    Text(
                      mail.createdAt.year == DateTime.now().year
                          ? DateFormat('MMM dd, kk:mm').format(mail.createdAt)
                          : DateFormat('MMM dd, yyyy, kk:mm')
                              .format(mail.createdAt),
                    ),
                  ],
                ),
                showTrailingIcon: isNarrow ? false : true,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      // child: Text(
                      //   mail.message,
                      //   style: TextStyle(
                      //     fontStyle: FontStyle.italic,
                      //   ),
                      // ),
                      child: mail.message == null
                          ? Text('Empty message')
                          : RichText(
                              text: stringParser(context, mail.message!),
                            ),
                    ),
                  ),
                ],
                onExpansionChanged: (isExpanded) async {
                  if (isExpanded && !mail.isRead) {
                    await operationInDB(context, 'UPDATE', 'mails', data: {
                      'is_read': true,
                    }, matchCriteria: {
                      'id': mail.id,
                    });
                  }
                },
              ),
            );
          },
        );
      },
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
        icon = Icon(Icons.mark_email_read);
        data = {'is_read': true};
        break;
      case 'markUnread':
        textMessage = 'Mark all as unread';
        confirmationMessage =
            'Are you sure you want to mark all mails as unread ?';
        successMessage = 'All ${mails.length} mails have been set to unread';
        icon = Icon(Icons.markunread);
        data = {'is_read': false};
        break;
      case 'delete':
        textMessage = 'Delete all';
        confirmationMessage =
            'Are you sure you want to throw all mails in the thrash ?';
        successMessage = 'All ${mails.length} mails will be deleted in 7 days';
        icon = Icon(Icons.delete, color: Colors.red);
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
          bool isOk = await operationInDB(
            context,
            'UPDATE',
            'mails',
            data: data,
            inFilterMatchCriteria: {
              'id': mails.map((mail) => mail.id).toList()
            },
          );

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

  Icon _getMailIcon(Mail mail) {
    if (mail.isTransferInfo) return Icon(iconTransfers, color: Colors.green);
    if (mail.isGameResult)
      return Icon(Icons.sports_soccer, color: Colors.green);
    if (mail.isSeasonInfo) return Icon(iconDetails, color: Colors.green);
    if (mail.isClubInfo) return Icon(iconClub, color: Colors.green);
    return Icon(Icons.label_important, color: Colors.green);
  }
}
