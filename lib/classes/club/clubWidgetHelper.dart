part of 'club.dart';

extension ClubWidgetHelper on Club {
  /// Clickable widget of the club name
  Widget getClubNameClickable(BuildContext context,
      {bool isRightClub = false}) {
    bool isMine =
        Provider.of<SessionProvider>(context).user!.selectedClub.id == id
            ? true
            : false;
    Text text = Text(
      nameClub,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontStyle: isMine ? FontStyle.italic : FontStyle.normal,
      ),
      overflow: TextOverflow.fade, // or TextOverflow.ellipsis
      maxLines: 1,
      softWrap: false,
    );
    Icon icon =
        Icon(isMine ? icon_home : Icons.sports_soccer_outlined, size: 30);

    return Row(
      mainAxisAlignment:
          isRightClub ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              ClubPage.route(id),
            );
          },
          child: Row(
            children: [
              if (isRightClub) icon else text,
              SizedBox(width: 6),
              if (isRightClub) text else icon,
            ],
          ),
        ),
      ],
    );
  }
}
