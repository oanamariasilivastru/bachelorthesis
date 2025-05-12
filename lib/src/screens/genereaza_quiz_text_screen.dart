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
  State<GenereazaQuizTextScreen> createState() =>
      _GenereazaQuizTextScreenState();
}

class _GenereazaQuizTextScreenState extends State<GenereazaQuizTextScreen> {
  final _textController = TextEditingController();
  final _numQController = TextEditingController(text: '10');
  bool _isLoading = false;
  String _errorMessage = '';
  List<QuizItem> _quizItems = [];
  int _timerSeconds = 60;

  static const Map<String, String> _languages = {
    'ro': 'Română',
    'en': 'English',
  };
  String _selectedLanguage = 'ro';

  String? get _token => AuthService.token;

  Future<void> _generateQuiz() async {
    final text = _textController.text.trim();
    final numQ = int.tryParse(_numQController.text) ?? 10;

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
      _quizItems = [];
    });

    try {
      // pick the right endpoint
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
          setState(() => _errorMessage = 'Răspuns neașteptat de la server.');
        } else {
          final items = raw.map((e) {
            final m = e as Map<String, dynamic>;
            return QuizItem(
              question: m['question'] as String? ?? '',
              options: List<String>.from(m['options'] as List<dynamic>),
              answer: m['answer'] as String? ?? '',
              // assuming your QuizItem has language + dateTaken
              language: _selectedLanguage,
              dateTaken: DateTime.now().toIso8601String(),
            );
          }).toList(growable: false);

          setState(() => _quizItems = items);
        }
      } else {
        setState(() =>
            _errorMessage = 'Eroare ${res.statusCode}: ${res.body}');
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
    const primary = Color(0xFF009688);
    const secondary = Color(0xFFFFB74D);
    final radius = BorderRadius.circular(16);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Quiz din Text'),
        backgroundColor: primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── LEFT PANEL ─────────────────────────
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: radius),
                    margin: const EdgeInsets.only(right: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _sectionHeader(
                            icon: Icons.text_snippet,
                            color: primary,
                            text: 'Text Sursă',
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _textController,
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: 'Li​pește aici textul sursă…',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: radius,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _sectionHeader(
                            icon: Icons.format_list_numbered,
                            color: secondary,
                            text: 'Nr. Întrebări',
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _numQController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '10',
                              filled: true,
                              fillColor: secondary.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: radius,
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _sectionHeader(
                            icon: Icons.language,
                            color: primary,
                            text: 'Limbă Quiz',
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: primary.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: radius,
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _languages.entries.map((e) {
                              return DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => _selectedLanguage = v!),
                          ),
                          const SizedBox(height: 24),
                          _sectionHeader(
                            icon: Icons.timer,
                            color: secondary,
                            text: 'Durata (secunde)',
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: _timerSeconds.toDouble(),
                            min: 0,
                            max: 300,
                            divisions: 30,
                            label:
                                _timerSeconds == 0 ? 'Fără timp' : '$_timerSeconds s',
                            activeColor: secondary,
                            onChanged: (v) =>
                                setState(() => _timerSeconds = v.round()),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
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
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: radius),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isLoading ? null : _generateQuiz,
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(_errorMessage,
                                style: TextStyle(color: secondary)),
                          ],
                          if (_quizItems.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            OutlinedButton(
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
                              style: OutlinedButton.styleFrom(
                                side:
                                    BorderSide(color: secondary, width: 2),
                                foregroundColor: secondary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: radius),
                              ),
                              child: const Text('Începe Quiz-ul'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── RIGHT PANEL ────────────────────────
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/quiz_context.png',
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      _HowItWorksCard(color: primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color color,
    required String text,
  }) =>
      Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(text,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      );
}

class _HowItWorksCard extends StatelessWidget {
  final Color color;
  const _HowItWorksCard({required this.color});

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Li​pești textul sursă.',
      'Setezi numărul de întrebări.',
      'Alegi limba quiz-ului.',
      'Glisezi pentru durata dorită.',
      'Apăși „Generează Quiz”.',
    ];
    return Card(
      elevation: 3,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cum funcționează?',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((e) {
              final idx = e.key + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('$idx',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.value,
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
