import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/classes/mail.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';

class MailsPage extends StatefulWidget {
  final int idClub;
  const MailsPage({Key? key, required this.idClub}) : super(key: key);

  static Route<void> route(int idClub) {
    return MaterialPageRoute(
      builder: (context) => MailsPage(idClub: idClub),
    );
  }

  @override
  State<MailsPage> createState() => _MailsPageState();
}

class _MailsPageState extends State<MailsPage> {
  late Stream<List<Mail>> _mailsStream;

  @override
  void initState() {
    _mailsStream = supabase
        .from('messages_mail')
        .stream(primaryKey: ['id'])
        .eq('id_club', widget.idClub)
        .map((maps) => maps.map((map) => Mail.fromMap(map)).toList());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Mail>>(
      stream: _mailsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<Mail> mails =
            snapshot.data!.where((mail) => mail.dateDelete == null).toList();
        List<Mail> mailsToDelete =
            snapshot.data!.where((mail) => mail.dateDelete != null).toList();
        return Scaffold(
          appBar: AppBar(
            title: Text('Mails (${mails.length})'),
          ),
          drawer: const AppDrawer(),
          body: MaxWidthContainer(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      buildTabWithIcon(Icons.inbox, 'Inbox (${mails.length})'),
                      buildTabWithIcon(Icons.auto_delete,
                          'Thrash (${mailsToDelete.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildInbox(context, mails),
                        _buildThrash(context, mailsToDelete),
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
            /// Mark all as read
            InkWell(
              onTap: () async {
                bool? shouldUpdate = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text(
                          'Are you sure you want to mark all mails as read?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (shouldUpdate == true) {
                  updateMailStatus(context,
                      mails.map((mail) => mail.id).toList(), {'is_read': true});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All mails has been set to read')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 3),
                    Text('Mark all as read'),
                  ],
                ),
              ),
            ),

            /// Mark all as unread
            InkWell(
              onTap: () async {
                bool? shouldUpdate = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text(
                          'Are you sure you want to mark all mails as unread?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (shouldUpdate == true) {
                  updateMailStatus(
                      context,
                      mails.map((mail) => mail.id).toList(),
                      {'is_read': false});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All mails has been set to unread')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Icon(Icons.markunread),
                    SizedBox(width: 3),
                    Text('Mark all as unread'),
                  ],
                ),
              ),
            ),

            /// Delete all
            InkWell(
              onTap: () async {
                bool? shouldUpdate = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content:
                          Text('Are you sure you want to delete all mails ?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (shouldUpdate == true) {
                  updateMailStatus(
                      context, mails.map((mail) => mail.id).toList(), {
                    'date_delete':
                        DateTime.now().add(Duration(days: 7)).toIso8601String()
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('All mails will be deleted in 7 days')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 3),
                    Text('Delete all'),
                  ],
                ),
              ),
            ),
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
            /// Mark all as read
            InkWell(
              onTap: () async {
                bool? shouldUpdate = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text(
                          'Are you sure you want to mark all mails as read?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (shouldUpdate == true) {
                  updateMailStatus(context,
                      mails.map((mail) => mail.id).toList(), {'is_read': true});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All mails has been set to read')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 3),
                    Text('Mark all as read'),
                  ],
                ),
              ),
            ),

            /// Mark all as unread
            InkWell(
              onTap: () async {
                bool? shouldUpdate = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text(
                          'Are you sure you want to mark all mails as unread?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (shouldUpdate == true) {
                  updateMailStatus(
                      context,
                      mails.map((mail) => mail.id).toList(),
                      {'is_read': false});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All mails has been set to unread')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Icon(Icons.markunread),
                    SizedBox(width: 3),
                    Text('Mark all as unread'),
                  ],
                ),
              ),
            ),

            /// Undelete all
            InkWell(
              onTap: () async {
                bool? shouldUpdate = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmation'),
                      content: Text(
                          'Are you sure you want to move back all mails to inbox ?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                        ),
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (shouldUpdate == true) {
                  updateMailStatus(
                      context,
                      mails.map((mail) => mail.id).toList(),
                      {'date_delete': null});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('All mails have been restored to the inbox')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 3),
                    Text('Restore all'),
                  ],
                ),
              ),
            ),
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
            return ExpansionTile(
              leading: isNarrow
                  ? null
                  : IconButton(
                      icon: mail.isRead
                          ? Icon(Icons.mark_email_read)
                          : Icon(Icons.mail),
                      onPressed: () {
                        if (mail.isRead) {
                          updateMailStatus(
                              context, [mail.id], {'is_read': false});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('The mail has been set to unread')),
                          );
                        } else {
                          updateMailStatus(
                              context, [mail.id], {'is_read': true});
                        }
                      },
                    ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isNarrow)
                    IconButton(
                      icon: mail.isRead
                          ? Icon(Icons.mark_email_read)
                          : Icon(Icons.mail),
                      onPressed: () {
                        if (mail.isRead) {
                          updateMailStatus(
                              context, [mail.id], {'is_read': false});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('The mail has been set to unread')),
                          );
                        } else {
                          updateMailStatus(
                              context, [mail.id], {'is_read': true});
                        }
                      },
                    ),
                  Text(mail.title),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: mail.isFavorite ? Colors.red : Colors.blueGrey,
                        ),
                        onPressed: () {
                          if (mail.isFavorite) {
                            updateMailStatus(
                                context, [mail.id], {'is_favorite': false});
                          } else {
                            updateMailStatus(
                                context, [mail.id], {'is_favorite': true});
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          if (mail.dateDelete == null) {
                            updateMailStatus(context, [
                              mail.id
                            ], {
                              'date_delete': DateTime.now()
                                  .add(Duration(days: 7))
                                  .toIso8601String()
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'The mail will be deleted in 7 days')),
                            );
                          } else {
                            updateMailStatus(
                                context, [mail.id], {'date_delete': null});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'The mail has been moved back to your inbox')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.calendar_month),
                  SizedBox(width: 3),
                  Text(
                    mail.createdAt.year == DateTime.now().year
                        ? DateFormat('MMM dd, kk:mm').format(mail.createdAt)
                        : DateFormat('MMM dd, yyyy, kk:mm')
                            .format(mail.createdAt),
                  ),
                  formSpacer6,
                  Expanded(
                    child: Text(
                      mail.message,
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.blueGrey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
              showTrailingIcon: isNarrow ? false : true,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    mail.message,
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              onExpansionChanged: (isExpanded) async {
                if (isExpanded && !mail.isRead) {
                  updateMailStatus(context, [mail.id], {'is_read': true});
                }
              },
            );
          },
        );
      },
    );
  }

  Future<void> updateMailStatus(BuildContext context, List<int> mailIds,
      Map<String, dynamic> updates) async {
    try {
      await supabase
          .from('messages_mail')
          .update(updates)
          .inFilter('id', mailIds);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating mail with ${updates}: $error')),
      );
    }
  }
}
