import 'package:flutter/material.dart';
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
            ),
            AboutListTile(
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
          ],
        ),
      ),
    );
  }
}
