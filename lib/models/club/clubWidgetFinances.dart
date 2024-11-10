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
        '${NumberFormat.decimalPattern().format(cash)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: cash > 0 ? Colors.green : Colors.red,
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
