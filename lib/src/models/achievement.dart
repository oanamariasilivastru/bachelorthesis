// lib/src/models/achievement.dart

class Achievement {
  final String id;
  final String title;
  final String description;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    // backend poate trimite is_unlocked ca int (0/1) sau bool
    final unlocked = json['is_unlocked'];
    final isUnlocked = unlocked is int ? unlocked == 1 : (unlocked as bool);
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isUnlocked: isUnlocked,
    );
  }
}
