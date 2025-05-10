// lib/src/providers/profile_provider.dart

import 'package:flutter/material.dart';
import 'package:app/src/models/user_profile.dart';
import 'package:app/src/services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  UserProfile? _profile;
  bool _isLoading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _api.fetchUserProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unlockAchievement(String id) async {
    await _api.unlockAchievement(id);
    await loadProfile();
  }

  Future<void> completeMission(String id) async {
    await _api.completeMission(id);
    await loadProfile();
  }
}
