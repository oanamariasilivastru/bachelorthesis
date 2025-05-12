// lib/src/models/quiz_history_item.dart

import 'dart:convert';

/// Un răspuns dintr-un quiz salvat:
class QuizQuestion {
  final String question;
  final String correctAnswer;
  final String userAnswer;
  final List<String> options;

  QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.userAnswer,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String? ?? '',
      correctAnswer: json['correct_answer'] as String? ?? '',
      userAnswer: json['user_answer'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }
}

/// Un quiz salvat:
class QuizHistoryItem {
  final int id;
  final DateTime dateTaken;
  final String language;     // 'ro' | 'en' etc.
  final String type;         // 'text' | 'pdf'
  final String context;
  final int? documentId;
  final List<QuizQuestion> questions;

  QuizHistoryItem({
    required this.id,
    required this.dateTaken,
    required this.language,
    required this.type,
    required this.context,
    this.documentId,
    required this.questions,
  });

  factory QuizHistoryItem.fromJson(Map<String, dynamic> json) {
    return QuizHistoryItem(
      id: json['id'] as int? ?? 0,
      dateTaken: DateTime.parse(json['date_taken'] as String),
      language: json['language'] as String? ?? 'ro',
      type: json['type'] as String? ?? 'text',
      context: json['context'] as String? ?? '',
      documentId: json['document_id'] as int?,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
