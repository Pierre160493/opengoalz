part of 'player.dart';

extension PlayerCardDetails on Player {
  Widget playerCardDetailsWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6.0),
          getPlayerMainInformation(context),
          const SizedBox(height: 6.0),
        ],
      ),
    );
  }
}
