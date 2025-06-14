import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/profile.dart';
import 'package:opengoalz/postgresql_requests.dart';
import 'package:opengoalz/widgets/perso_alert_dialog_box.dart';

class AddCreditsTile extends StatelessWidget {
  final Profile user;
  final int creditsToAdd;
  final double creditsGiftedPercentage; // Percentage of credits gifted

  const AddCreditsTile({
    Key? key,
    required this.user,
    required this.creditsToAdd,
    required this.creditsGiftedPercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int creditsGifted =
        (creditsToAdd * creditsGiftedPercentage / 100).round();

    return ListTile(
      leading: Icon(Icons.add_card, size: iconSizeMedium, color: Colors.green),
      title: Row(
        children: [
          Text('$creditsToAdd',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              )),
          if (creditsGifted > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.yellow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.5),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard,
                      color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '+$creditsGifted Gifted (${creditsGiftedPercentage.toStringAsFixed(1)}%)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      shape: shapePersoRoundedBorder(),
      subtitle: Row(
        children: [
          Text(
            'Add ',
            style: styleItalicBlueGrey,
          ),
          Text((creditsToAdd + creditsGifted).toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.green,
              )),
          Text(
            ' credits to your account.',
            style: styleItalicBlueGrey,
          ),
        ],
      ),
      onTap: () async {
        bool confirm = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return persoAlertDialogWithConstrainedContent(
                  title: const Text('Confirm Purchase'),
                  content: Column(
                    children: [
                      Text(
                          'Are you sure you want to add $creditsToAdd credits to your account ?'),
                      if (creditsGifted > 0)
                        Text(
                            'You will also receive $creditsGifted gifted credits !')
                    ],
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: persoCancelRow(),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: persoValidRow('Confirm'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ) ??
            false;

        if (confirm) {
          await operationInDB(
            context,
            'UPDATE',
            'profiles',
            data: {
              'credits_available':
                  user.creditsAvailable + creditsToAdd + creditsGifted,
            },
            matchCriteria: {
              'uuid_user': user.id,
            },
            messageSuccess:
                '$creditsToAdd credits added successfully to your account. You also received $creditsGifted gifted credits!',
          );

          Navigator.of(context).pop(); // Close the dialog
        }
      },
    );
  }
}
