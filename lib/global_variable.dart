import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/pages/home_page.dart';
import 'package:provider/provider.dart';
import '../classes/club.dart';

class SessionProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  int nClubInList = 0;
  late Club
      selectedClub; // Regular variable for storing a single instance of Club
  late final StreamController<bool> _isLoggedInController;
  late final StreamController<int> _nClubInListController;
  late final StreamController<List<Club>> _clubStreamController;

  SessionProvider() {
    _isLoggedInController = StreamController<bool>.broadcast();
    _nClubInListController = StreamController<int>.broadcast();
    _clubStreamController = StreamController<List<Club>>.broadcast();
  }

  Stream<bool> get isLoggedInStream => _isLoggedInController.stream;
  Stream<int> get nClubInListStream => _nClubInListController.stream;
  Stream<List<Club>> get clubStream => _clubStreamController.stream;

  void setLoggedIn(bool value) {
    isLoggedIn = value;
    _isLoggedInController.add(value); // Add value to stream
    notifyListeners();
  }

  void setnClubInList(int value) {
    nClubInList = value;
    _nClubInListController.add(value); // Add value to stream
    notifyListeners();
  }

  void setselectedClub(Club club) {
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
            .map((map) => Club.fromMap(map: map, myUserId: userId))
            .toList())
        .listen((clubs) {
          _clubStreamController.add(clubs);
        });
    notifyListeners();
  }

  @override
  void dispose() {
    _isLoggedInController.close(); // Close the stream controller
    _nClubInListController.close(); // Close the stream controller
    _clubStreamController.close();
    super.dispose();
  }
}

void navigateToHomePage(BuildContext context) {
  final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
  sessionProvider.setLoggedIn(true); // Set isLoggedIn to true
  sessionProvider.updateClubStream(
      supabase.auth.currentUser!.id); // Update the club stream
  Club? selectedClub;

  sessionProvider.clubStream.listen((clubs) {
    for (Club club in clubs) {
      selectedClub ??= club;
      if (club.is_default) {
        sessionProvider.setnClubInList(clubs.indexOf(club));
        selectedClub = club;
      }
    }
    sessionProvider.setselectedClub(selectedClub!);
  });

  Navigator.of(context).pushAndRemoveUntil(HomePage.route(), (route) => false);
}
