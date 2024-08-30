part of 'club.dart';

extension ClubWidgetFinances on Club {
  Widget getClubCash() {
    return ListTile(
      leading: Icon(
        iconMoney,
        color: Colors.green, // Adjust icon color as needed
        size: iconSizeLarge,
      ),
      title: Text(
        '${NumberFormat.decimalPattern().format(lisCash.last)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: lisCash.last > 0 ? Colors.green : Colors.red,
        ),
      ),
      subtitle: Text(
        'Available Cash',
        style: TextStyle(
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
