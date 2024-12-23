import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/pages/login_page.dart';
import 'package:opengoalz/provider_theme_app.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => SettingsPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: MaxWidthContainer(
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Tooltip(
                message: 'Switch between light and dark theme',
                child: Text('Dark Theme'),
              ),
              trailing: Switch(
                value: Provider.of<ThemeProvider>(context).isDarkTheme,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme();
                },
              ),
              shape: shapePersoRoundedBorder(),
            ),
            ListTile(
              // leading: Icon(Icons.brightness_6),
              title: Tooltip(
                message: 'Release version',
                child: Text('Version 1.1.5'),
              ),

              shape: shapePersoRoundedBorder(),
            ),
            ListTile(
              leading: Icon(Icons.local_activity),
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
            ListTile(
              title: AboutListTile(
                icon: Icon(Icons.info),
                applicationIcon: Container(
                  width: 120, // Set width
                  height: 120, // Set height
                  child: Image.asset('assets/icon/opengoalz.png'),
                ),
                applicationName: 'OpenGoalZ',
                applicationVersion: '0.0.0',
                applicationLegalese: '© OpenGoalZ 2024',
                aboutBoxChildren: <Widget>[
                  Text('Thank you for using our app !'),
                  Text('Hope you\'re enjoying it.'),
                  Text(
                      'Feel free to contact us on our discord server if you have questions.'),
                ],
              ),
              shape: shapePersoRoundedBorder(),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
              title: Text('Delete your account'),
              onTap: () async {
                // Prompt confirmation dialog before deleting the account
                bool? isConfirmed = await context.showConfirmationDialog(
                    'Are you sure you want to delete your account ?');

                if (isConfirmed) {
                  try {
                    // Delete the user account
                    await supabase.auth.admin
                        .deleteUser(supabase.auth.currentUser!.id);
                    context.showSnackBar('Account deleted',
                        icon: Icon(Icons.delete_forever, color: Colors.red));
                    Navigator.of(context).pushAndRemoveUntil(
                      LoginPage.route(),
                      (route) => false,
                    );
                  } catch (error) {
                    context.showSnackBarError('Error deleting the account');
                  }
                }
              },
              shape: shapePersoRoundedBorder(false),
            ),
          ],
        ),
      ),
    );
  }
}
