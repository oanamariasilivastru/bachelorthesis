// lib/src/models/user_profile.dart

import 'achievement.dart';
import 'mission.dart';

class UserProfile {
  final int userId;
  final String name;
  final String email;
  final int currentStreak;
  final DateTime? lastActiveDate;
  final List<Achievement> achievements;
  final List<Mission> missions;

  UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.currentStreak,
    this.lastActiveDate,
    required this.achievements,
    required this.missions,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      currentStreak: json['current_streak'] as int,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.parse(json['last_active_date'] as String)
          : null,
      achievements: (json['achievements'] as List<dynamic>)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      missions: (json['missions'] as List<dynamic>)
          .map((m) => Mission.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
