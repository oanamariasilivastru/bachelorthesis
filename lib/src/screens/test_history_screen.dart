// lib/src/screens/quiz_history_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:app/src/models/quiz_history_item.dart';
import 'package:app/src/services/api_service.dart';

/// Ecranul care afișează istoricul tuturor quiz‑urilor salvate pe backend.
/// 
/// Folosește [ApiService.fetchQuizHistory] care întoarce deja o listă de
/// [QuizHistoryItem]; nu mai există parsing manual în layer‑ul de UI.
class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  late Future<List<QuizHistoryItem>> _futureHistory;
  final _api = ApiService();
  static const _primary = Color(0xFF009688);

  @override
  void initState() {
    super.initState();
    _futureHistory = _api.fetchQuizHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<List<QuizHistoryItem>>(
              future: _futureHistory,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _primary));
                }
                if (snap.hasError) {
                  return Center(child: Text('Eroare: ${snap.error}'));
                }
                final quizzes = snap.data ?? [];
                if (quizzes.isEmpty) {
                  return const Center(child: Text('Nu există quiz‑uri.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizzes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildQuizCard(quizzes[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /* ---------------------------------------------------------------------- */
  /*  HEADER                                                                */
  /* ---------------------------------------------------------------------- */

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, Color(0xFF26A69A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          BackButton(color: Colors.white),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Istoric Quiz‑uri',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48), // balans vizual
        ],
      ),
    );
  }

  /* ---------------------------------------------------------------------- */
  /*  CARD QUIZ                                                             */
  /* ---------------------------------------------------------------------- */

  Widget _buildQuizCard(QuizHistoryItem quiz) {
    final date = quiz.dateTaken.toLocal();
    final dateFmt = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} – ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}'
        '  •  ${quiz.questions.length} întrebări';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        leading: Container(
          decoration: BoxDecoration(color: _primary.withOpacity(0.2), shape: BoxShape.circle),
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.quiz_outlined, color: _primary, size: 28),
        ),
        title: Text('Quiz #${quiz.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(dateFmt),
        children: quiz.questions.map(_buildQuestionTile).toList(),
      ),
    );
  }

  /* ---------------------------------------------------------------------- */
  /*  TILE ÎNTREBARE                                                        */
  /* ---------------------------------------------------------------------- */

  Widget _buildQuestionTile(QuizQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(q.question, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ...q.options.map((opt) {
          final isCorrect = opt == q.correctAnswer;
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              dense: true,
              title: Text(opt),
              trailing: isCorrect ? const Icon(Icons.check, color: Colors.green) : null,
            ),
          );
        }),
        const SizedBox(height: 8),
        const Divider(height: 1),
      ],
    );
  }
}
