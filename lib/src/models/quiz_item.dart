// lib/src/models/quiz_item.dart

/// Model comun pentru un item de quiz
class QuizItem {
  final String question;
  final String answer;
  final List<String> options;

  QuizItem({
    required this.question,
    required this.answer,
    required this.options,
  });
}
