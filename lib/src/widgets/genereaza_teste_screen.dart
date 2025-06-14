// lib/src/screens/genereaza_teste_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/quiz_item.dart';
import '../services/auth_service.dart';
import '../screens/quiz_session_screen.dart';

class GenereazaTesteScreen extends StatefulWidget {
  const GenereazaTesteScreen({Key? key}) : super(key: key);

  @override
  State<GenereazaTesteScreen> createState() => _GenereazaTesteScreenState();
}

class _GenereazaTesteScreenState extends State<GenereazaTesteScreen> {
  /* ------------------------------------------------------------------
   * Configurare locală
   * ---------------------------------------------------------------- */
  static const _backend = 'http://127.0.0.1:5000'; // ← schimbă dacă rulezi altundeva

  /// Limbi suportate de backend (cheie = cod, valoare = label în UI)
  static const Map<String, String> _languages = {
    'ro': 'Română',
    'en': 'English',
  };

  /* ------------------------------------------------------------------
   * State
   * ---------------------------------------------------------------- */
  File? _pdfFile;
  final _numQController = TextEditingController(text: '3');

  bool _isLoading = false;
  String _errorMessage = '';
  List<QuizItem> _quizItems = [];

  /// limba selectată (default ro)
  String _selectedLanguage = 'ro';

  /// timp pentru fiecare întrebare (slider)
  int _timerSeconds = 60;

  /* ------------------------------------------------------------------
   * Pick PDF
   * ---------------------------------------------------------------- */
  Future<void> _pickPdf() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (res != null && res.files.single.path != null) {
      setState(() => _pdfFile = File(res.files.single.path!));
    }
  }

  /* ------------------------------------------------------------------
   * Send request către backend și generează quiz-ul
   * ---------------------------------------------------------------- */
  Future<void> _generateQuiz() async {
    final numQ = int.tryParse(_numQController.text) ?? 0;
    if (_pdfFile == null) {
      return setState(() => _errorMessage = 'Selectează un fișier PDF.');
    }
    if (numQ <= 0) {
      return setState(() => _errorMessage = 'Numărul de întrebări trebuie să fie > 0.');
    }
    final token = AuthService.token;
    if (token == null) {
      return setState(() => _errorMessage = 'Trebuie să fii autentificat.');
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _quizItems.clear();
    });

    try {
      // 1️⃣  Formăm cererea multipart
      final uri = Uri.parse('$_backend/generate_test');
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['language']      = _selectedLanguage         // ← limbă trimisă backend-ului
        ..fields['num_questions'] = numQ.toString()
        ..files.add(
          await http.MultipartFile.fromPath(
            'document',
            _pdfFile!.path,
            contentType: MediaType('application', 'pdf'),
          ),
        );

      // 2️⃣  Trimitem și primim răspunsul complet
      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final raw = body['test'] as List<dynamic>?;

        if (raw == null) {
          setState(() => _errorMessage =
              body['error'] ?? 'Răspuns neașteptat de la server.');
        } else {
          // mapăm obiectele în QuizItem
          final items = raw
              .whereType<Map<String, dynamic>>()
              .map((m) => QuizItem(
                    question : m['question'] as String? ?? '',
                    options  : List<String>.from(m['distractors'] ?? []),
                    answer   : m['correct_answer'] as String? ?? '',
                    dateTaken: DateTime.now().toIso8601String(),
                    language : _selectedLanguage,
                  ))
              .toList(growable: false);

          setState(() => _quizItems = items);
        }
      } else {
        setState(() => _errorMessage =
            'Eroare ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Eroare: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /* ------------------------------------------------------------------
   * UI
   * ---------------------------------------------------------------- */
  @override
  void dispose() {
    _numQController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6C5B7B);
    const secondary = Color(0xFFC06C84);
    final radius = BorderRadius.circular(16);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Teste din PDF'),
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
                /* --------------------- FORMULĂR --------------------- */
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
                          _sectionHeader('Încarcă PDF', Icons.upload_file, primary),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _pickPdf,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: radius),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(_pdfFile == null
                                ? 'Selectează fișier'
                                : 'PDF: ${_pdfFile!.path.split(Platform.pathSeparator).last}'),
                          ),
                          const SizedBox(height: 24),

                          _sectionHeader('Număr întrebări', Icons.format_list_numbered, primary),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _numQController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(secondary, radius, 'Ex: 5'),
                          ),
                          const SizedBox(height: 24),

                          _sectionHeader('Limbă', Icons.language, secondary),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            items: _languages.entries
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            decoration: _inputDecoration(secondary, radius, null),
                            onChanged: _isLoading
                                ? null
                                : (v) => setState(() => _selectedLanguage = v!),
                          ),
                          const SizedBox(height: 24),

                          _sectionHeader('Durata (secunde)', Icons.timer, primary),
                          const SizedBox(height: 12),
                          Slider(
                            value: _timerSeconds.toDouble(),
                            min: 10,
                            max: 300,
                            divisions: 290,
                            label: '$_timerSeconds s',
                            activeColor: primary,
                            onChanged: (v) =>
                                setState(() => _timerSeconds = v.round()),
                          ),
                          Center(
                            child: Text('$_timerSeconds secunde',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 24),

                          _sectionHeader('Generează Test', Icons.playlist_add_check, primary),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _generateQuiz,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: radius),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Generează'),
                          ),

                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(_errorMessage,
                                style: TextStyle(
                                    color: secondary, fontSize: 16)),
                          ],

                          if (_quizItems.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primary, width: 2),
                                foregroundColor: primary,
                                shape: RoundedRectangleBorder(borderRadius: radius),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => QuizSessionScreen(
                                    items: _quizItems,
                                    language: _selectedLanguage,
                                    timerSeconds: _timerSeconds,
                                  ),
                                ));
                              },
                              child: const Text('Începe Testul'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                /* --------------------- Coloană secundară (imagine + paşi) --------------------- */
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Image.asset('assets/images/generate_tests.png'),
                      const SizedBox(height: 24),
                      const _HowItWorksCard(color: secondary),
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

  /* Utilitare UI -------------------------------------------------------------- */
  InputDecoration _inputDecoration(
          Color fill, BorderRadius radius, String? hint) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: fill.withOpacity(0.1),
        border:
            OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
      );

  Widget _sectionHeader(String txt, IconData icn, Color col) => Row(
        children: [
          CircleAvatar(
              radius: 18,
              backgroundColor: col.withOpacity(0.2),
              child: Icon(icn, color: col)),
          const SizedBox(width: 12),
          Text(txt,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: col)),
        ],
      );
}

/* ------------------------------------------------------------------
 * Card explicativ (nemodificat faţă de versiunea anterioară)
 * ---------------------------------------------------------------- */
class _HowItWorksCard extends StatelessWidget {
  final Color color;
  const _HowItWorksCard({required this.color});

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Încarci PDF-ul din device.',
      'Selectezi limba testului.',
      'Stabilești numărul de întrebări.',
      'Stabilești durata în secunde.',
      'Generezi testul și începi.',
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cum funcționează?',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 16),
            ...steps.asMap().entries.map((e) {
              final idx = e.key + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: color,
                      child: Text('$idx',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.value)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
