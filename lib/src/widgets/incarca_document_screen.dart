// lib/src/screens/incarca_document_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../services/auth_service.dart';
import 'response_card.dart';

class IncarcaDocumentScreen extends StatefulWidget {
  const IncarcaDocumentScreen({Key? key}) : super(key: key);

  @override
  State<IncarcaDocumentScreen> createState() => _IncarcaDocumentScreenState();
}

class _IncarcaDocumentScreenState extends State<IncarcaDocumentScreen> {
  String? _documentPath;
  String _selectedLanguage = 'ro';
  final _questionController = TextEditingController();
  String _backendResponse = '';
  String _errorMessage = '';
  bool _isLoading = false;

  String? get _token => AuthService.token;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _documentPath = result.files.single.path);
    }
  }

  Future<void> _saveDocumentRecord(String answer) async {
    final url = Uri.parse('http://127.0.0.1:5000/save_document_record');
    final title =
        _documentPath?.split(Platform.pathSeparator).last ?? 'Document';
    final record = {
      'title': title,
      'file_path': _documentPath,
      'question': _questionController.text,
      'answer': answer,
      'language': _selectedLanguage,          // <<< limbă trimisă aici
    };
    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(record),
    );
  }

  Future<void> _uploadDocument() async {
    if (_documentPath == null || _questionController.text.isEmpty) {
      setState(() => _errorMessage = 'Selectează un document și o întrebare.');
      return;
    }
    if (_token == null) {
      setState(() => _errorMessage = 'Te rugăm să te loghezi mai întâi.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _backendResponse = '';
    });
    try {
      final uri = Uri.parse('http://127.0.0.1:5000/process_pdf');
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $_token'
        ..files.add(await http.MultipartFile.fromPath(
          'document',
          _documentPath!,
          contentType: MediaType('application', 'pdf'),
        ))
        ..fields['question'] = _questionController.text
        ..fields['language'] = _selectedLanguage;  // <<< și aici

      final response = await http.Response.fromStream(await req.send());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data["answer"] as String? ?? '';
        setState(() {
          _backendResponse =
              'Răspuns: $answer\nLocație: ${data["location"]}';
        });
        // Salvăm și istoricul cu limbă
        await _saveDocumentRecord(answer);
      } else {
        setState(() => _errorMessage =
            'Eroare server ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Eroare: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accents = [
      Color(0xFF4A90E2),
      Color(0xFF50E3C2),
    ];
    final primary = accents[0];
    final secondary = accents[1];
    final radius = BorderRadius.circular(16);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Încarcă Document'),
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
                // Formular
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
                              icon: Icons.insert_drive_file,
                              color: primary,
                              text: 'Document'),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload_file),
                            label: Text(_documentPath == null
                                ? 'Selectează fișier'
                                : _documentPath!
                                    .split(Platform.pathSeparator)
                                    .last),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: radius),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: _isLoading ? null : _pickDocument,
                          ),
                          const SizedBox(height: 24),
                          _sectionHeader(
                              icon: Icons.language,
                              color: secondary,
                              text: 'Limba documentului'),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedLanguage,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: secondary.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: radius,
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                            iconEnabledColor: secondary,
                            items: const [
                              DropdownMenuItem(
                                  value: 'ro', child: Text('Română')),
                              DropdownMenuItem(
                                  value: 'en', child: Text('Engleză')),
                            ],
                            onChanged:
                                _isLoading ? null : (v) => setState(() {
                                      _selectedLanguage = v!;
                                    }),
                          ),
                          const SizedBox(height: 24),
                          _sectionHeader(
                              icon: Icons.question_answer,
                              color: primary,
                              text: 'Întrebarea ta'),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _questionController,
                            maxLines: 3,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Scrie întrebarea aici...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: radius,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(
                                _isLoading ? 'Încarcă...' : 'Generează răspuns'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: radius),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                            onPressed: _isLoading ? null : _uploadDocument,
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(_errorMessage,
                                style: TextStyle(
                                    color: secondary, fontSize: 14)),
                          ],
                          if (_backendResponse.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            ResponseCard(responseText: _backendResponse),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Ilustrație + pași
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/document_illustration.png',
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
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
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
      'Încarci PDF sau DOC de pe device.',
      'Selectezi limba documentului.',
      'Introduci întrebarea dorită.',
      'Apăși „Generează răspuns”.',
      'Vizualizezi răspunsul și istoricul.',
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
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('$idx',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(e.value, style: const TextStyle(fontSize: 16)),
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
