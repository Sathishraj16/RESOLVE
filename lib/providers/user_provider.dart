import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  String _language = 'English';

  bool get notificationsEnabled => _notificationsEnabled;
  String get language => _language;

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }
}
