import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import '../classes/club.dart';

class SessionProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  int nClubInList = 0;
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
