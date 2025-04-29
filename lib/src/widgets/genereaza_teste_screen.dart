// lib/src/screens/genereaza_test_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:app/src/services/auth_service.dart';

/// Ecran pentru istoricul testelor generate
class GenereazaTesteScreen extends StatefulWidget {
  const GenereazaTesteScreen({Key? key}) : super(key: key);

  @override
  State<GenereazaTesteScreen> createState() => _GenereazaTesteScreenState();
}

class _GenereazaTesteScreenState extends State<GenereazaTesteScreen> {
  late Future<List<TestRecord>> _futureTests;

  @override
  void initState() {
    super.initState();
    _futureTests = _fetchTestRecords();
  }

  Future<List<TestRecord>> _fetchTestRecords() async {
    final token = AuthService.token;
    if (token == null) throw Exception('Not authenticated');
    final url = Uri.parse('http://127.0.0.1:5000/test_records');
    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to load test history: ${res.body}');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['test_records'] as List<dynamic>? ?? [];
    return list.map((e) => TestRecord.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Istoric Teste'),
        backgroundColor: cs.primary,
      ),
      body: FutureBuilder<List<TestRecord>>(
        future: _futureTests,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Eroare: ${snap.error}'));
          }
          final tests = snap.data!;
          if (tests.isEmpty) {
            return const Center(child: Text('Nu există teste generate.'));
          }
          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: tests.length,
            itemBuilder: (ctx, i) {
              final rec = tests[i];
              final dt = DateTime.tryParse(rec.dateTaken);
              final formattedDate = dt != null
                  ? DateFormat('dd MMM yyyy • HH:mm').format(dt)
                  : rec.dateTaken;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ExpansionTile(
                  leading: Icon(Icons.quiz, color: cs.primary),
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  collapsedBackgroundColor: cs.surface,
                  backgroundColor: cs.surfaceVariant,
                  title: Text(
                    formattedDate,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: cs.onSurface,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left:
                              BorderSide(color: cs.primary, width: 4),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Text(
                        rec.context,
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurface.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: rec.questions.map((q) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q.question,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        // Afișăm toate opțiunile:
                        ...q.options.map((opt) {
                          final isChosen = opt == q.userAnswer;
                          final isCorrect = opt == q.correctAnswer;
                          Icon leadingIcon;
                          if (isCorrect) {
                            leadingIcon = Icon(Icons.check_circle,
                                color: Colors.green);
                          } else if (isChosen) {
                            leadingIcon = Icon(Icons.radio_button_checked,
                                color: cs.primary);
                          } else {
                            leadingIcon = Icon(Icons.radio_button_off,
                                color: cs.onSurface.withOpacity(0.6));
                          }
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                leadingIcon,
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isCorrect
                                          ? Colors.green.shade800
                                          : cs.onSurface,
                                      fontWeight: isCorrect
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const Divider(height: 24),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Model pentru un test generat
class TestRecord {
  final String dateTaken;
  final String context;
  final List<QuestionRecord> questions;

  TestRecord({
    required this.dateTaken,
    required this.context,
    required this.questions,
  });

  factory TestRecord.fromJson(Map<String, dynamic> j) {
    final qs = (j['questions'] as List<dynamic>?) ?? [];
    return TestRecord(
      dateTaken: j['date_taken'] ?? '',
      context: j['context'] ?? '',
      questions:
          qs.map((e) => QuestionRecord.fromJson(e)).toList(),
    );
  }
}

/// Model pentru fiecare întrebare din test
class QuestionRecord {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final List<String> options;

  QuestionRecord({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    required this.options,
  });

  factory QuestionRecord.fromJson(Map<String, dynamic> j) {
    final rawOpts = j['options'] as List<dynamic>? ?? [];
    final opts = rawOpts.map((o) => o.toString()).toList();
    return QuestionRecord(
      question: j['question'] ?? '',
      userAnswer: j['user_answer'] ?? '',
      correctAnswer: j['correct_answer'] ?? '',
      options: opts,
    );
  }
}
