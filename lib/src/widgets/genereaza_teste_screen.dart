// lib/src/screens/genereaza_teste_screen.dart

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app/src/screens/quiz_session_screen.dart';
import 'package:app/src/models/quiz_item.dart';

class GenereazaTesteScreen extends StatefulWidget {
  const GenereazaTesteScreen({Key? key}) : super(key: key);

  @override
  State<GenereazaTesteScreen> createState() => _GenereazaTesteScreenState();
}

class _GenereazaTesteScreenState extends State<GenereazaTesteScreen> {
  File? _pdfFile;
  bool _isLoading = false;
  String _errorMessage = '';
  List<QuizItem> _quizItems = [];
  int _timerSeconds = 60;

  static const Map<String, String> _languages = {
    'ro': 'Română',
    'en': 'English',
  };
  String _selectedLanguage = 'ro';

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pdfFile = File(result.files.single.path!));
    }
  }

  // TODO: Înlocuiește cu întrebările complete
  List<QuizItem> _getHardcodedQuizRo() => [ /* … întrebări RO …*/ ];
  List<QuizItem> _getHardcodedQuizEn() => [ /* … întrebări EN …*/ ];

  Future<void> _generateQuiz() async {
    if (_pdfFile == null) {
      setState(() => _errorMessage = 'Selectează un fișier PDF.');
      return;
    }
    if (_timerSeconds <= 0) {
      setState(() => _errorMessage = 'Durata trebuie să fie > 0.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _quizItems = [];
    });
    // simulare generare
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _quizItems = (_selectedLanguage == 'ro')
          ? _getHardcodedQuizRo()
          : _getHardcodedQuizEn();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Paletă pastel
    const accents = [
      Color(0xFF6C5B7B), // violet închis pastel
      Color(0xFFC06C84), // roz coral pastel
    ];
    final primary = accents[0];
    final secondary = accents[1];
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
                // ─── Stânga: formular + butoane ───────────────────
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
                          // PDF picker
                          _sectionHeader(
                              icon: Icons.upload_file,
                              color: primary,
                              text: 'Încarcă PDF'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: radius),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _isLoading ? null : _pickPdf,
                            child: Text(
                              _pdfFile == null
                                  ? 'Selectează fișier'
                                  : 'PDF: ${_pdfFile!.path.split(Platform.pathSeparator).last}',
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Language selector
                          _sectionHeader(
                              icon: Icons.language,
                              color: secondary,
                              text: 'Alege limbă'),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: radius,
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: secondary.withOpacity(0.1),
                            ),
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                            iconEnabledColor: secondary,
                            items: _languages.entries
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            onChanged: _isLoading
                                ? null
                                : (v) => setState(
                                    () => _selectedLanguage = v!),
                          ),
                          const SizedBox(height: 24),

                          // Slider orizontal pentru timer
                          _sectionHeader(
                              icon: Icons.timer,
                              color: primary,
                              text: 'Durata test (secunde)'),
                          const SizedBox(height: 12),
                          Slider(
                            value: _timerSeconds.toDouble(),
                            min: 10,
                            max: 300,
                            divisions: 290,
                            activeColor: primary,
                            inactiveColor: primary.withOpacity(0.2),
                            label: '$_timerSeconds s',
                            onChanged: (value) {
                              setState(() {
                                _timerSeconds = value.toInt();
                              });
                            },
                          ),
                          Center(
                            child: Text(
                              '$_timerSeconds secunde',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primary),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Generate button
                          _sectionHeader(
                              icon: Icons.playlist_add_check,
                              color: primary,
                              text: 'Generează Test'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: radius),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                            ),
                            onPressed: _isLoading ? null : _generateQuiz,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
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
                                    BorderSide(color: primary, width: 2),
                                foregroundColor: primary,
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: radius),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                              ),
                              child: const Text('Începe Testul'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ─── Dreapta: imagine + pași ───────────────────
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/generate_tests.png',
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      _HowItWorksCard(color: secondary),
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
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(text,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  final Color color;
  const _HowItWorksCard({required this.color});

  @override
  Widget build(BuildContext context) {
    final steps = [
      'Încarci PDF-ul din device.',
      'Selectezi limba testului.',
      'Stabilești durata în secunde.',
      'Generezi testul și aștepți.',
      'Începi testul apăsând butonul.',
    ];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
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
