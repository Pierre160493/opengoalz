import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/provider_theme_app.dart';
import 'package:opengoalz/widgets/goBackToolTip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class SettingsPage extends StatelessWidget {
  SettingsPage();

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => SettingsPage());
  }

  Future<String> _readVersion() async {
    try {
      final file = File('version.txt');
      return await file.readAsString();
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: goBackIconButton(context),
      ),
      body: MaxWidthContainer(
        child: ListView(
          children: <Widget>[
            /// ListTile for changing the theme
            ListTile(
              leading: Icon(Icons.brightness_6,
                  color: Colors.yellow, size: iconSizeMedium),
              title: Text('Dark Theme'),
              subtitle: Text('Switch between light and dark theme',
                  style: styleItalicBlueGrey),
              trailing: Switch(
                value: Provider.of<ThemeProvider>(context).isDarkTheme,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
              ),
              shape: shapePersoRoundedBorder(),
            ),

            /// ListTile for inviting someone to create an account
            ListTile(
              leading: Icon(Icons.local_activity,
                  color: Colors.green, size: iconSizeMedium),
              title: Text('Invite someone to create his account'),
              onTap: () async {
                // Show a dialog box to enter an email address
                final TextEditingController emailController =
                    TextEditingController();
                final String? email = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Enter Email Address'),
                      content: TextField(
                        controller: emailController,
                        decoration:
                            InputDecoration(hintText: 'email@example.com'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Send Invitation'),
                          onPressed: () {
                            Navigator.of(context).pop(emailController.text);
                          },
                        ),
                      ],
                    );
                  },
                );

                // If email is null, the user canceled the dialog
                if (email == null || email.isEmpty) {
                  return;
                }

                // Send an invitation email to the specified email address
                await supabase.auth.admin.inviteUserByEmail(email);

                context.showSnackBar('Invitation sent successfully to ${email}',
                    icon: Icon(Icons.email, color: Colors.green));
              },
              shape: shapePersoRoundedBorder(),
            ),

            /// ListTile for version information
            FutureBuilder<String>(
              future: _readVersion(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Tooltip(
                      message: 'Release version',
                      child: Text('Loading version...'),
                    ),
                    shape: shapePersoRoundedBorder(),
                  );
                } else if (snapshot.hasError) {
                  return ListTile(
                    title: Tooltip(
                      message: 'Release version',
                      child: Text('Error loading version'),
                    ),
                    shape: shapePersoRoundedBorder(),
                  );
                } else {
                  return ListTile(
                    leading: Icon(Icons.info,
                        color: Colors.blue, size: iconSizeMedium),
                    title: Text('Version ${snapshot.data}'),
                    subtitle: Text(
                      'Version of the app you are currently using.',
                      style: styleItalicBlueGrey,
                    ),
                    shape: shapePersoRoundedBorder(),
                  );
                }
              },
            ),

            /// ListTile for displaying app information
            FutureBuilder<String>(
              future: _readVersion(),
              builder: (context, snapshot) {
                return ListTile(
                  title: AboutListTile(
                    icon: Icon(Icons.info),
                    applicationIcon: Container(
                      width: 120, // Set width
                      height: 120, // Set height
                      child: Image.asset('assets/icon/opengoalz.png'),
                    ),
                    applicationName: 'OpenGoalZ',
                    applicationVersion: snapshot.data ?? 'Unknown',
                    applicationLegalese: '© OpenGoalZ 2024',
                    aboutBoxChildren: <Widget>[
                      Text('Thank you for using our app !'),
                      Text('Hope you\'re enjoying it.'),
                      Text(
                          'Feel free to contact us on our discord server if you have questions.'),
                    ],
                  ),
                  shape: shapePersoRoundedBorder(),
                );
              },
            ),

            /// ListTile for changing the language
            ListTile(
              leading: Icon(Icons.language,
                  color: Colors.green, size: iconSizeMedium),
              title: Text('Change Language'),
              subtitle: Text('Select your preferred language',
                  style: styleItalicBlueGrey),
              onTap: () {
                context.showSnackBarError(
                  'Language selection is not implemented yet.',
                  icon: Icon(Icons.language, color: Colors.orange),
                );
              },
              shape: shapePersoRoundedBorder(Colors.orange),
            ),

            /// ListTile for deleting the account
            ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: Colors.red,
                size: iconSizeMedium,
              ),
              title: Text('Delete your account'),
              subtitle: Text(
                'Permanently delete your account and all associated data.',
                style: styleItalicBlueGrey,
              ),
              onTap: () async {
                // Prompt confirmation dialog before deleting the account
                bool? isConfirmed = await context.showConfirmationDialog(
                    'Are you sure you want to delete your account ?');

                if (isConfirmed) {
                  try {
                    /// Delete the user account
                    await operationInDB(context, 'UPDATE', 'profiles',
                        data: {
                          'date_delete': DateTime.now()
                              // .add(Duration(days: 30))
                              .add(Duration(
                                  days:
                                      30)) // Set to yesterday to delete immediately
                              .toIso8601String(),
                        },
                        matchCriteria: {
                          'uuid_user': supabase.auth.currentUser!.id
                        },
                        messageSuccess:
                            'Your account will be deleted in 30 days. You can still log in to cancel the deletion.');

                    await supabase.auth.signOut(); // Sign out the user
                    Navigator.of(context).pushAndRemoveUntil(
                      LoginPage.route(),
                      (route) => false,
                    );
                  } catch (error) {
                    context.showSnackBarError(
                        'Error deleting the account: ${error.toString()}');
                  }
                }
              },
              shape: shapePersoRoundedBorder(Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
