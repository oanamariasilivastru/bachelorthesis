// lib/src/screens/genereaza_quiz_text_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/src/services/auth_service.dart';
import 'package:app/src/models/quiz_item.dart';
import 'quiz_session_screen.dart';

class GenereazaQuizTextScreen extends StatefulWidget {
  const GenereazaQuizTextScreen({Key? key}) : super(key: key);

  @override
  _GenereazaQuizTextScreenState createState() =>
      _GenereazaQuizTextScreenState();
}

class _GenereazaQuizTextScreenState extends State<GenereazaQuizTextScreen> {
  final _textController = TextEditingController();
  final _numQController = TextEditingController(text: '3');
  bool _isLoading = false;
  String _errorMessage = '';
  List<QuizItem> _quizItems = [];
  int _timerSeconds = 60;

  static const Map<String, String> _languages = {
    'ro': 'Română',
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
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
      // Alege endpoint-ul în funcție de limbă
      final path = _selectedLanguage == 'ro'
          ? 'generate_mcq_ro'
          : 'generate_mcq_en';
      final uri = Uri.parse('http://127.0.0.1:5000/$path');

      final res = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
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
              _errorMessage = data['error'] ?? 'Răspuns neașteptat.');
        } else {
          final items = raw.map((e) {
            final m = e as Map<String, dynamic>;
            return QuizItem(
              question: m['question'] as String,
              options: List<String>.from(m['options'] as List),
              answer: m['answer'] as String,
            );
          }).toList(growable: false);

          setState(() => _quizItems = items);
        }
      } else {
        setState(
            () => _errorMessage = 'Eroare ${res.statusCode}: ${res.body}');
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Text sursă
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
                    hintText: 'Li​pește aici textul sursă...',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nr întrebări + limbă
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
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLanguage = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Slider timer
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

            // Generează quiz
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Generează Quiz'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _generateQuiz,
              ),
            ),

            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_errorMessage, style: TextStyle(color: cs.error)),
            ],

            // Start quiz
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
                            side:
                                BorderSide(color: cs.onSecondaryContainer),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
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
                          child: const Text('Începe Quiz-ul'),
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
