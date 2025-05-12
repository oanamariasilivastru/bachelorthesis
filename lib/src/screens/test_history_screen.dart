// lib/src/screens/quiz_history_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/src/models/quiz_history_item.dart';
import 'package:app/src/services/api_service.dart';

/// Afișează istoricul tuturor quiz-urilor salvate pe backend,
/// cu filtre pe limbă și interval de date și sortare după dată.
class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});
  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  late Future<List<QuizHistoryItem>> _futureHistory;
  final _api = ApiService();
  static const _primary = Color(0xFF009688);

  // ─── filtre locale ─────────────────────────────────────────────
  String _langFilter = 'All';         // All | ro | en
  DateTimeRange? _dateRange;          // interval selectat
  bool _sortDescending = true;        // desc vs asc

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildFilters(),
          ),
          Expanded(
            child: FutureBuilder<List<QuizHistoryItem>>(
              future: _futureHistory,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: _primary),
                  );
                }
                if (snap.hasError) {
                  return Center(child: Text('Eroare: ${snap.error}'));
                }

                // 1️⃣ lista originală
                var quizzes = snap.data!;

                // 2️⃣ filtrare după limbă
                if (_langFilter != 'All') {
                  quizzes = quizzes
                      .where((q) => q.language.toLowerCase() == _langFilter)
                      .toList();
                }

                // 3️⃣ filtrare după interval de date
                if (_dateRange != null) {
                  quizzes = quizzes.where((q) {
                    final d = q.dateTaken.toLocal();
                    return !d.isBefore(_dateRange!.start) &&
                           !d.isAfter (_dateRange!.end);
                  }).toList();
                }

                // 4️⃣ sortare după dată
                quizzes.sort((a, b) {
                  final da = a.dateTaken, db = b.dateTaken;
                  return _sortDescending
                      ? db.compareTo(da)
                      : da.compareTo(db);
                });

                // 5️⃣ fallback când nu mai rămâne nimic
                if (quizzes.isEmpty) {
                  return const Center(child: Text('Nu există quiz-uri.'));
                }

                // 6️⃣ afișare
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

  // ────────────────────────────────────────────────────────────────
  // HEADER
  // ────────────────────────────────────────────────────────────────

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
              'Istoric Quiz-uri',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // FILTRE (limbă, dată, sortare)
  // ────────────────────────────────────────────────────────────────

  Widget _buildFilters() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        // Limbă
        DropdownButton<String>(
          value: _langFilter,
          items: const [
            DropdownMenuItem(value: 'All', child: Text('Toate limbile')),
            DropdownMenuItem(value: 'ro',  child: Text('Română')),
            DropdownMenuItem(value: 'en',  child: Text('Engleză')),
          ],
          onChanged: (v) => setState(() => _langFilter = v!),
        ),

        // Interval de date
        OutlinedButton.icon(
          icon: const Icon(Icons.date_range),
          label: Text(
            _dateRange == null
              ? 'Toate datele'
              : '${_dateRange!.start.year}-${_dateRange!.start.month.toString().padLeft(2,'0')}-${_dateRange!.start.day.toString().padLeft(2,'0')}'
                ' → '
                '${_dateRange!.end.year}-${_dateRange!.end.month.toString().padLeft(2,'0')}-${_dateRange!.end.day.toString().padLeft(2,'0')}',
          ),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _dateRange = picked);
          },
        ),

        // Clear date
        if (_dateRange != null)
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Șterge filtru dată',
            onPressed: () => setState(() => _dateRange = null),
          ),

        // Sortare
        IconButton(
          icon: Icon(
            _sortDescending
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          ),
          tooltip: 'Sortare după dată',
          onPressed: () => setState(() => _sortDescending = !_sortDescending),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  // CARD-UL FIECĂRUI QUIZ
  // ────────────────────────────────────────────────────────────────

  Widget _buildQuizCard(QuizHistoryItem quiz) {
    final d = quiz.dateTaken.toLocal();
    final labelDate = '${d.day.toString().padLeft(2,'0')}/'
        '${d.month.toString().padLeft(2,'0')}/'
        '${d.year}  ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        leading: Container(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: _primary.withOpacity(0.2), shape: BoxShape.circle
          ),
          padding: const EdgeInsets.all(12),
          child: const Icon(Icons.quiz_outlined, color: _primary, size: 28),
        ),
        title: Text(
          'Quiz #${quiz.id} • ${quiz.language.toUpperCase()}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('$labelDate  •  ${quiz.questions.length} întrebări'),
        children: quiz.questions.map((q) {
          return _buildQuestionTile(q);
        }).toList(),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // RÂND PENTRU FIECARE ÎNTREBARE DIN QUIZ
  // ────────────────────────────────────────────────────────────────

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
              trailing: isCorrect
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
            ),
          );
        }),
        const SizedBox(height: 8),
        const Divider(height: 1),
      ],
    );
  }
}
