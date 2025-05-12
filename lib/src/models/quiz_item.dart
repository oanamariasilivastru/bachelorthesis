// lib/src/models/quiz_item.dart

class QuizItem {
  /// Textul întrebării
  final String question;

  /// Răspunsul corect
  final String answer;

  /// Toate opţiunile de răspuns (incluzând răspunsul corect)
  final List<String> options;

  /// Timestamp ISO-8601 când a fost generat/scris quiz-ul
  final String dateTaken;

  /// Codul limbii, ex. "ro" sau "en"
  final String language;

  QuizItem({
    required this.question,
    required this.answer,
    required this.options,
    required this.dateTaken,
    required this.language,
  });

  /// Constructor specific endpoint-ului de generare MCQ
  factory QuizItem.fromGeneratedJson(
    Map<String, dynamic> json, {
    required String dateTaken,
    required String language,
  }) {
    return QuizItem(
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      answer: json['answer'] as String? ?? '',
      dateTaken: dateTaken,
      language: language,
    );
  }

  /// Constructor specific istoricului (/test_records)
  factory QuizItem.fromHistoryJson(Map<String, dynamic> json) {
    return QuizItem(
      question: json['question'] as String? ?? '',
      options: (json['options_json'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      answer: json['correct_answer'] as String? ?? '',
      dateTaken: json['date_taken'] as String? ?? '',
      language: json['language'] as String? ?? 'ro',
    );
  }

  /// Constructor “catch-all”: alege automat parser-ul potrivit
  factory QuizItem.fromJson(
    Map<String, dynamic> json, {
    String? dateTaken,
    String? language,
  }) {
    if (json.containsKey('correct_answer')) {
      // Format istoric
      return QuizItem.fromHistoryJson(json);
    } else {
      // Format generat MCQ
      return QuizItem.fromGeneratedJson(
        json,
        dateTaken: dateTaken ?? DateTime.now().toIso8601String(),
        language: language ?? 'en',
      );
    }
  }

  /// Serializare înapoi în JSON
  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'answer': answer,
        'date_taken': dateTaken,
        'language': language,
      };
}
