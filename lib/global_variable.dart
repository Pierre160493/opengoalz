import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/classes/club_view.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/home_page.dart';
import 'package:provider/provider.dart';

class SessionProvider extends ChangeNotifier {
  late ClubView
      selectedClub; // Regular variable for storing a single instance of Club
  late final StreamController<List<ClubView>> _clubStreamController;

  SessionProvider() {
    _clubStreamController = StreamController<List<ClubView>>.broadcast();
  }

  Stream<List<ClubView>> get clubStream => _clubStreamController.stream;

  void setselectedClub(ClubView club) {
    selectedClub = club;
    notifyListeners();
  }

  void updateClubStream(String userId) {
    supabase
        .from('view_clubs')
        .stream(primaryKey: ['id'])
        .eq('id_user', userId)
        .order('created_at')
        .map((maps) => maps
            .map((map) => ClubView.fromMap(map: map, myUserId: userId))
            .toList())
        .listen((clubs) {
          _clubStreamController.add(clubs);
        });
    notifyListeners();
  }

  @override
  void dispose() {
    _clubStreamController.close();
    super.dispose();
  }
}

void navigateToHomePage(BuildContext context) {
  final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  sessionProvider.updateClubStream(
      supabase.auth.currentUser!.id); // Update the club stream
  ClubView? selectedClub;

  sessionProvider.clubStream.listen((clubs) {
    for (ClubView club in clubs) {
      selectedClub ??= club;
      if (club.is_default) {
        selectedClub = club;
      }
    }
    sessionProvider.setselectedClub(selectedClub!);
  });

  Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (route) => false);
}
