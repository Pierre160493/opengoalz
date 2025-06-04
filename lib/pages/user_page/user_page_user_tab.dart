import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/functions/stringParser.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/pages/user_page/user_page_add_club_tile.dart';
import 'package:opengoalz/pages/user_page/user_page_add_player_tile.dart';
import 'package:opengoalz/widgets/add_credits_tile.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';

class UserPageUserTab extends StatelessWidget {
  final Profile user;

  const UserPageUserTab({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return persoAlertDialogWithConstrainedContent(
                        title: const Text('Error'),
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
                        content: const Text('No events found for this user.'),
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
              const Text('Available Credits: '),
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
                    title: Text(
                        '${user.creditsAvailable} credits available, get more !'),
                    content: Column(
                      children: [
                        AddCreditsTile(
                            user: user,
                            creditsToAdd: 100,
                            creditsGiftedPercentage: 0),
                        AddCreditsTile(
                            user: user,
                            creditsToAdd: 500,
                            creditsGiftedPercentage: 10),
                        AddCreditsTile(
                            user: user,
                            creditsToAdd: 1000,
                            creditsGiftedPercentage: 15),
                        AddCreditsTile(
                            user: user,
                            creditsToAdd: 2000,
                            creditsGiftedPercentage: 20),
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
        UserPageAddClubTile(user: user),

        /// Player tile
        UserPageAddPlayerTile(user: user),
      ],
    );
  }
}
