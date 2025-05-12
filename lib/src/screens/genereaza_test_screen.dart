// lib/src/screens/genereaza_quiz_text_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/src/models/quiz_item.dart';
import 'package:app/src/services/auth_service.dart';
import 'quiz_session_screen.dart';

class GenereazaQuizTextScreen extends StatefulWidget {
  const GenereazaQuizTextScreen({Key? key}) : super(key: key);

  @override
  State<GenereazaQuizTextScreen> createState() =>
      _GenereazaQuizTextScreenState();
}

class _GenereazaQuizTextScreenState extends State<GenereazaQuizTextScreen> {
  final _textController = TextEditingController();
  final _numQController = TextEditingController(text: '3');
  bool _isLoading = false;
  String _errorMessage = '';
  List<QuizItem> _quizItems = [];
  int _timerSeconds = 60;

  static const _backendBase = 'http://127.0.0.1:5000';
  static const Map<String, String> _languages = {
    'ro': 'Română',
    'en': 'English',
  };
  String _selectedLanguage = 'ro';
  String? get _token => AuthService.token;

  Future<void> _generateQuiz() async {
    final text = _textController.text.trim();
    final numQ = int.tryParse(_numQController.text) ?? 3;

    if (text.isEmpty) {
      setState(() => _errorMessage = 'Introdu textul sursă.');
      return;
    }
    if (_token == null) {
      setState(() => _errorMessage = 'Te rugăm să te autentifici.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _quizItems.clear();
    });

    try {
      // choose the correct endpoint
      final endpoint = _selectedLanguage == 'en'
          ? '/generate_mcq_en'
          : '/generate_mcq_ro';
      final uri = Uri.parse('$_backendBase$endpoint');

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'text': text,
          'num_questions': numQ,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final raw = data['questions'] as List<dynamic>?;

        if (raw == null) {
          setState(() =>
              _errorMessage = data['error'] ?? 'Răspuns neașteptat de la server.');
        } else {
          final items = raw
              .whereType<Map<String, dynamic>>()
              .map((m) => QuizItem(
                    question: m['question'] as String? ?? '',
                    options: List<String>.from(m['options'] as List? ?? []),
                    answer: m['answer'] as String? ?? '',
                    dateTaken: DateTime.now().toIso8601String(),
                    language: _selectedLanguage,
                  ))
              .toList(growable: false);

          setState(() => _quizItems = items);
        }
      } else {
        setState(() => _errorMessage = 'Eroare ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Eroare: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _numQController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz din Text'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      backgroundColor: cs.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ─── Source Text ─────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _textController,
                  maxLines: 6,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Li​pește aici textul sursă…',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── # Questions & Language ────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numQController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nr. întrebări',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      labelText: 'Limbă',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _languages.entries
                        .map((e) =>
                            DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLanguage = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ─── Timer Slider ──────────────────────────
            Row(
              children: [
                const Text('Timer:'),
                Expanded(
                  child: Slider(
                    value: _timerSeconds.toDouble(),
                    min: 0,
                    max: 300,
                    divisions: 30,
                    label: _timerSeconds == 0
                        ? 'Fără timp'
                        : '${_timerSeconds}s',
                    onChanged: (v) =>
                        setState(() => _timerSeconds = v.round()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ─── Generate Button ───────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.onPrimary,
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Generează Quiz'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _generateQuiz,
              ),
            ),

            // ─── Error Message ────────────────────────
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_errorMessage, style: TextStyle(color: cs.error)),
            ],

            // ─── Ready Card ───────────────────────────
            if (_quizItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                color: cs.secondaryContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Quiz-ul este gata! Ai ${_quizItems.length} întrebări.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onSecondaryContainer),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.onSecondaryContainer),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => QuizSessionScreen(
                                  items: _quizItems,
                                  language: _selectedLanguage,
                                  timerSeconds: _timerSeconds,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Începe Quiz-ul',
                            style:
                                TextStyle(color: cs.onSecondaryContainer),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
