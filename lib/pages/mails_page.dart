import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/models/mails/mail.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/goBack_tool_tip.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:opengoalz/widgets/tab_widget_with_icon.dart';
import 'package:provider/provider.dart';
import 'package:opengoalz/models/mails/mail_filter_dialog.dart';
import 'package:opengoalz/models/mails/mail_list.dart';

import '../models/club/class/club_widgets.dart';

class MailsPage extends StatefulWidget {
  const MailsPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => MailsPage(),
    );
  }

  @override
  State<MailsPage> createState() => _MailsPageState();
}

class _MailsPageState extends State<MailsPage> {
  bool _filterGameResult = true;
  bool _filterTransferInfo = true;
  bool _filterSeasonInfo = true;
  bool _filterClubInfo = true;

  @override
  void initState() {
    super.initState();
  }

  bool _areAllFiltersTrue() {
    return _filterGameResult &&
        _filterTransferInfo &&
        _filterSeasonInfo &&
        _filterClubInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSessionProvider>(
      builder: (context, UserSessionProvider, child) {
        Club club = UserSessionProvider.user.selectedClub!;

        /// Get all mails that are not deleted
        final List<Mail> mailsAll =
            club.mails.where((mail) => mail.dateDelete == null).toList();

        /// Get all mails that are not deleted and filtered
        final mailsFiltered = _applyFilters(mailsAll);

        /// Get all mails that are deleted and filtered
        final mailsThrashFiltered = _applyFilters(UserSessionProvider
            .user.selectedClub!.mails
            .where((mail) => mail.dateDelete != null)
            .toList());

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                getClubNameClickable(context,club),
                Text(' Mails (${mailsAll.length})',
                    style: TextStyle(fontSize: fontSizeLarge)),
              ],
            ),
            leading: goBackIconButton(context),
            actions: [
              IconButton(
                tooltip: 'Filter mails',
                icon: Icon(
                  Icons.filter_list, size: iconSizeLarge,
                  color: _areAllFiltersTrue() ? Colors.green : Colors.orange,
                ),
                onPressed: () async {
                  await showMailFilterDialog(context, mailsAll, setState);
                  setState(() {});
                },
              ),
            ],
          ),
          body: MaxWidthContainer(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      buildTabWithIcon(
                          icon: Icons.inbox,
                          text: 'Inbox (${mailsFiltered.length})'),
                      buildTabWithIcon(
                          icon: iconMailDelete,
                          text: 'Thrash (${mailsThrashFiltered.length})'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        MailList(mails: mailsFiltered, isTrash: false),
                        MailList(mails: mailsThrashFiltered, isTrash: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Mail> _applyFilters(List<Mail> mails) {
    if (_areAllFiltersTrue()) return mails;
    return mails.where((mail) {
      if (_filterGameResult && mail.isGameResult) return true;
      if (_filterTransferInfo && mail.isTransferInfo) return true;
      if (_filterSeasonInfo && mail.isSeasonInfo) return true;
      if (_filterClubInfo && mail.isClubInfo) return true;
      return false;
    }).toList();
  }
}
