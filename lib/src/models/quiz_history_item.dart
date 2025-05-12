// lib/src/models/quiz_history_item.dart
class QuizHistoryItem {
  final int id;
  final String context;
  final DateTime dateTaken;
  final List<QuizQuestion> questions;

  QuizHistoryItem({
    required this.id,
    required this.context,
    required this.dateTaken,
    required this.questions,
  });

  factory QuizHistoryItem.fromJson(Map<String, dynamic> json) {
    final qs = (json['questions'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(QuizQuestion.fromJson)
        .toList();

    return QuizHistoryItem(
      id: json['id'] as int,
      context: json['context'] as String,
      dateTaken: DateTime.parse(json['date_taken'] as String),
      questions: qs,
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? userAnswer;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      correctAnswer: json['correct_answer'] as String,
      userAnswer: json['user_answer'] as String?,
    );
  }
}
