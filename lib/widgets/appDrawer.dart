import 'package:flutter/material.dart';
import 'package:opengoalz/pages/chat_page.dart';
import 'package:opengoalz/pages/player_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add your NavigationBar content here
      child: ListView(
        children: [
          Container(
            color: Colors.grey, // Set the background color to grey
            child: ListTile(
              leading: const Icon(Icons.add_home_work), // Add the chat icon
              title: const Text(
                'Club',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.0, // Change underline thickness
                  // decorationStyle:
                  //     TextDecorationStyle.dotted, // Change underline style
                ),
              ),
              onTap: () {
                // Handle navigation to item 1
              },
            ),
          ),
          ListTile(
            // leading: const Icon(Icons.attach_money), // Add the chat icon
            leading: const Icon(Icons.savings_outlined), // Add the chat icon
            title: const Text('Finances'),
            onTap: () {
              // Handle navigation to item 2
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.waving_hand_outlined), // Add the chat icon
            title: const Text('Fans'),
            onTap: () {
              // Handle navigation to item 2
            },
          ),
          ListTile(
            // leading: const Icon(Icons.fort_outlined), // Add the chat icon
            leading: const Icon(Icons.stadium_outlined), // Add the chat icon
            title: const Text('Stadium'),
            onTap: () {
              // Handle navigation to item 2
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.engineering_outlined), // Add the chat icon
            title: const Text('Staff'),
            onTap: () {
              // Handle navigation to item 2
            },
          ),
          ListTile(
            leading: const Icon(Icons.healing), // Add the chat icon
            title: const Text('Medics'),
            onTap: () {
              // Handle navigation to item 2
            },
          ),
          Container(
            color: Colors.grey, // Set the background color to grey
            child: ListTile(
              leading:
                  const Icon(Icons.group_add_outlined), // Add the chat icon
              title: const Text(
                'Main Team',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.0, // Change underline thickness
                  // decorationStyle:
                  //     TextDecorationStyle.dotted, // Change underline style
                ),
              ),
              onTap: () {
                // Handle navigation to item 1
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.diversity_3), // Add the chat icon
            title: const Text('Players'),
            onTap: () {
              // Navigate to player page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PlayerPage(), // Replace PlayerPage() with your player page widget
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange), // Add the chat icon
            title: const Text('Transfers'),
            onTap: () {
              // Handle navigation to item 2
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_outlined), // Add the chat icon
            title: const Text('Games'),
            onTap: () {
              // Handle navigation to item 2
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.emoji_events_outlined), // Add the chat icon
            title: const Text('Series'),
            onTap: () {
              // Handle navigation to item 2
            },
          ),
          ListTile(
            leading: const Icon(
                // Icons.data_exploration_outlined), // Add the chat icon
                Icons.query_stats), // Add the chat icon
            title: const Text('Training'),
            onTap: () {
              // Handle navigation to item 2
            },
          ),
          // Add non-clickable Text widgets for information
          Container(
            color: Colors.grey, // Set the background color to grey
            child: ListTile(
              leading: const Icon(
                  // Icons.child_friendly_outlined), // Add the chat icon
                  Icons.school_outlined), // Add the chat icon
              title: const Text(
                'Young Team',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.0, // Change underline thickness
                  // decorationStyle:
                  //     TextDecorationStyle.dotted, // Change underline style
                ),
              ),
              onTap: () {
                // Handle navigation to item 1
              },
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'This is some information about the app or the navigation.',
              style: TextStyle(
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          ListTile(
            // leading: const Icon(Icons.chat), // Add the chat icon
            leading: const Icon(Icons.wechat_outlined), // Add the chat icon
            title: const Text('Chat'),
            onTap: () {
              Navigator.of(context).push(ChatPage.route());
            },
          ),
        ],
      ),
    );
  }
}
