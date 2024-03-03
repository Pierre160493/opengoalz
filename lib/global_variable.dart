import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opengoalz/constants.dart';
import '../classes/club.dart';

class SessionProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  late final StreamController<bool> _isLoggedInController;
  late final StreamController<List<Club>> _clubStreamController;

  SessionProvider() {
    _isLoggedInController = StreamController<bool>.broadcast();
    _clubStreamController = StreamController<List<Club>>.broadcast();
  }

  Stream<bool> get isLoggedInStream => _isLoggedInController.stream;
  Stream<List<Club>> get clubStream => _clubStreamController.stream;

  void setLoggedIn(bool value) {
    isLoggedIn = value;
    _isLoggedInController.add(value); // Add value to stream
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
    _clubStreamController.close();
    super.dispose();
  }
}
