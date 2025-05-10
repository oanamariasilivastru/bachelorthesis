// lib/src/models/mission.dart

class Mission {
  final String id;
  final String description;
  final bool isCompleted;

  Mission({
    required this.id,
    required this.description,
    required this.isCompleted,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    final completed = json['is_completed'];
    final isCompleted = completed is int ? completed == 1 : (completed as bool);
    return Mission(
      id: json['id'] as String,
      description: json['description'] as String,
      isCompleted: isCompleted,
    );
  }
}
