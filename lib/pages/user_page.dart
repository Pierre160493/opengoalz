import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/functions/loadingCircularAndText.dart';
import 'package:opengoalz/functions/stringParser.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/player/class/player.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/pages/settings_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/widgets/appDrawer.dart';
import 'package:opengoalz/models/mails/mailsWidget.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';
import 'package:opengoalz/widgets/sendMail.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:opengoalz/widgets/tickingTime.dart';
import 'package:opengoalz/widgets/userClubsTileWidget.dart';
import 'package:opengoalz/widgets/userPageListOfClubs.dart';
import 'package:opengoalz/widgets/userPageListOfPlayers.dart';
import 'package:opengoalz/widgets/userPlayersTileWidget.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class UserPage extends StatefulWidget {
  final String? userName;
  final String? uuidUser;

  const UserPage({Key? key, this.userName, this.uuidUser}) : super(key: key);

  static Route<void> route({String? userName, String? uuidUser}) {
    return MaterialPageRoute(
      builder: (context) => UserPage(userName: userName, uuidUser: uuidUser),
    );
  }

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Stream<Profile> _userStream;
  bool _hasShownDeletionDialog =
      false; // Flag to ensure the dialog is shown only once

  @override
  void initState() {
    super.initState();
    if (widget.userName != null || widget.uuidUser != null) {
      final connectedUser =
          Provider.of<UserSessionProvider>(context, listen: false).user;
      if (widget.userName == connectedUser.username ||
          widget.uuidUser == connectedUser.id) {
        // Use the data from the provider if the username or UUID matches the connected user
        _userStream = Stream.value(connectedUser);
      } else {
        // Fetch the data from the database if the username or UUID does not match the connected user
        _userStream = supabase
            .from('profiles')
            .stream(primaryKey: ['id'])
            .eq(widget.uuidUser != null ? 'uuid_user' : 'username',
                widget.uuidUser ?? widget.userName as Object)
            .map((maps) => maps.map((map) => Profile.fromMap(map)).first)
            .switchMap((Profile user) {
              return supabase
                  .from('clubs')
                  .stream(primaryKey: ['id'])
                  .eq('username', user.username)
                  .order('user_since')
                  .map((maps) => maps.map((map) => Club.fromMap(map)).toList())
                  .map((List<Club> clubs) {
                    user.clubs = clubs;
                    return user;
                  });
            })
            .switchMap((Profile user) {
              return supabase
                  .from('players')
                  .stream(primaryKey: ['id'])
                  .eq('username', user.username)
                  .map((maps) =>
                      maps.map((map) => Player.fromMap(map, user)).toList())
                  .map((List<Player> players) {
                    user.playersIncarnated = players;
                    return user;
                  });
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userName != null || widget.uuidUser != null) {
      return StreamBuilder<Profile>(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCircularAndText('Loading user...');
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('User not found'));
          }
          Profile user = snapshot.data!;
          return _buildUserWidget(user);
        },
      );
    } else {
      return Consumer<UserSessionProvider>(
        builder: (context, UserSessionProvider, child) {
          Profile? user = UserSessionProvider.user;
          return _buildUserWidget(user);
        },
      );
    }
  }

  Widget _buildUserWidget(Profile? user) {
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('User not found, please try again'),
            formSpacer12,
            ElevatedButton(
              onPressed: () async {
                await supabase.auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  LoginPage.route(),
                  (route) => false,
                );
              },
              child: const Text('Reset App'),
            ),
          ],
        ),
      );
    }

    // Show dialog if the connected user's account is marked for deletion
    if (user.isConnectedUser &&
        user.dateDelete != null &&
        !_hasShownDeletionDialog) {
      _hasShownDeletionDialog = true; // Set the flag to true
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          _showAccountDeletionDialog(context, user);
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: user.getUserName(context),
        actions: [
          /// Account deletion notice
          if (user.dateDelete != null)
            IconButton(
              tooltip: 'Account scheduled for deletion',
              icon:
                  Icon(Icons.warning, size: iconSizeMedium, color: Colors.red),
              onPressed: () {
                _showAccountDeletionDialog(context, user);
              },
            ),

          /// Settings button
          IconButton(
            tooltip: 'Open Settings Page',
            onPressed: () {
              Navigator.of(context).push(SettingsPage.route());
            },
            icon:
                Icon(Icons.settings, size: iconSizeMedium, color: Colors.green),
          ),

          /// Reload page button
          IconButton(
            tooltip: 'Reload User Page',
            onPressed: () async {
              // Refetch the user
              await Provider.of<UserSessionProvider>(context, listen: false)
                  .providerFetchUser(context,
                      userId: supabase.auth.currentUser!.id);

              /// Reload the UserPage
              Navigator.of(context)
                  .pushAndRemoveUntil(UserPage.route(), (route) => false);
              context.showSnackBarSuccess('User and Page reloaded');
            },
            icon:
                Icon(Icons.refresh, size: iconSizeMedium, color: Colors.green),
          ),
          user.isConnectedUser
              ? mailToolTip(context, user)
              : Tooltip(
                  message: 'Send Mail',
                  child: IconButton(
                    onPressed: () async {
                      sendMailDialog(context,
                          idClub: user.selectedClub!.id,
                          username: user.username);
                    },
                    icon: Icon(Icons.quick_contacts_mail, size: iconSizeSmall),
                  ),
                ),
          user.isConnectedUser
              ? Tooltip(
                  message: 'Logout',
                  child: IconButton(
                    onPressed: () async {
                      bool logoutConfirmed =
                          await context.showConfirmationDialog(
                              'Are you sure you want to log out?');
                      if (logoutConfirmed == true) {
                        await supabase.auth.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                            LoginPage.route(), (route) => false);
                      }
                    },
                    icon: Icon(Icons.logout,
                        size: iconSizeSmall, color: Colors.red),
                  ),
                )
              : Provider.of<UserSessionProvider>(context, listen: false)
                  .user
                  .returnToConnectedUserIconButton(context),
        ],
      ),
      drawer: const AppDrawer(),
      body: MaxWidthContainer(
          child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                buildTabWithIcon(
                    icon: iconClub,
                    text: user.clubs.length == 0
                        ? 'No club'
                        : user.clubs.length == 1
                            ? '1 Club'
                            : '${user.clubs.length} clubs',
                    iconColor:
                        user.clubs.length == 0 ? Colors.red : Colors.green),
                buildTabWithIcon(
                    icon: iconPlayers,
                    text: user.playersIncarnated.length == 0
                        ? 'No player'
                        : user.playersIncarnated.length == 1
                            ? '1 player'
                            : '${user.playersIncarnated.length} players',
                    iconColor: user.playersIncarnated.length == 0
                        ? Colors.red
                        : Colors.green),
                buildTabWithIcon(icon: Icons.description, text: 'User'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  userClubListWidget(context, user),
                  userPlayerListWidget(context, user),
                  _getUserWidget(user),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  void _showAccountDeletionDialog(BuildContext context, Profile user) {
    /// If the account is not scheduled for deletion, show an error message
    if (user.dateDelete == null)
      context.showSnackBarError('Account is not scheduled for deletion.');

    /// Show a dialog with the date scheduled for deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return persoAlertDialogWithConstrainedContent(
          title: ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text(
                'Account scheduled for deletion on ${formatDate(user.dateDelete!)}.'),
            subtitle: tickingTimeWidget(user.dateDelete!),
            shape: shapePersoRoundedBorder(),
          ),
          content: formSpacer3,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                /// Button to close the dialog
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: persoValidRow('Ok'),
                ),

                /// Button to cancel the account deletion
                TextButton(
                  onPressed: () async {
                    bool cancelConfirmed = await context.showConfirmationDialog(
                        'Are you sure you want to cancel the account deletion?');
                    if (cancelConfirmed == true) {
                      /// Cancel deletion by setting date_delete to null
                      await operationInDB(context, 'UPDATE', 'profiles',
                          data: {
                            'date_delete': null, // Cancel the deletion
                          },
                          matchCriteria: {
                            'uuid_user': supabase.auth.currentUser!.id
                          },
                          messageSuccess:
                              'Account deletion cancelled successfully. Glad to have you back!');

                      Navigator.of(context).pop();

                      /// Reload the UserPage
                      Navigator.of(context).pushAndRemoveUntil(
                          UserPage.route(), (route) => false);
                    }
                  },
                  child: persoRowWithIcon(
                    Icons.cancel,
                    'Cancel Deletion',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _getUserWidget(Profile user) {
    return Column(
      children: [
        /// User listtile
        ListTile(
          shape: shapePersoRoundedBorder(),
          leading: Icon(
            iconUser,
            color: Colors.green,
            size: iconSizeMedium,
          ),
          title: Text('Username: ${user.username}'),
          subtitle: Row(
            children: [
              Icon(
                Icons.timer,
                size: iconSizeSmall,
                color: Colors.green,
              ),
              Text(
                'Since: ${DateFormat.yMMMMd('en_US').format(user.createdAt)}',
                style: styleItalicBlueGrey,
              ),
            ],
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return FutureBuilder<List<dynamic>>(
                  future: supabase
                      .from('profile_events')
                      .select('created_at, description')
                      .eq('uuid_user', user.id)
                      .order('created_at', ascending: false),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return persoAlertDialogWithConstrainedContent(
                        title: Text('Error'),
                        content:
                            Text('Failed to load events: ${snapshot.error}'),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: persoRowWithIcon(Icons.close, 'Close',
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return persoAlertDialogWithConstrainedContent(
                        title: Text('List of events of ${user.username}'),
                        content: Text('No events found for this user.'),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: persoRowWithIcon(Icons.close, 'Close',
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    final events = snapshot.data!;
                    return persoAlertDialogWithConstrainedContent(
                      title: Text('List of events of ${user.username}'),
                      content: Column(
                        children: [
                          ...events.map<Widget>((event) => ListTile(
                                title: RichText(
                                    text: stringParser(
                                        context, event['description'])),
                                subtitle: Text(
                                  formatDate(
                                      DateTime.parse(event['created_at'])),
                                  style: styleItalicBlueGrey,
                                ),
                                shape: shapePersoRoundedBorder(),
                              )),
                        ],
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: persoRowWithIcon(Icons.close, 'Close',
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),

        /// Credits tile
        ListTile(
          shape: shapePersoRoundedBorder(),
          leading: Icon(
            iconCredits,
            color: Colors.green,
            size: iconSizeMedium,
          ),
          title: Row(
            children: [
              Text('Available Credits: '),
              Text(user.creditsAvailable.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          subtitle: const Text(
              'Use credits to manage more clubs and players and more',
              style: styleItalicBlueGrey),
          trailing: IconButton(
            icon:
                Icon(Icons.add_card, size: iconSizeMedium, color: Colors.green),
            tooltip: 'Add Credits',
            onPressed: () {
              /// Show a dialog with the user's credits to add more credits
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return persoAlertDialogWithConstrainedContent(
                    title: Text('${user.creditsAvailable} credits available'),
                    content: Column(
                      children: [
                        Text('Not yet implemented'),
                      ],
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: persoCancelRow),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),

        /// Club tile
        UserClubsTileWidget(user: user),

        /// Player tile
        UserPlayersTileWidget(user: user),
      ],
    );
  }
}
