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
      'date_uploaded': DateTime.now().toIso8601String(),
      'question': _questionController.text,
      'answer': answer,
      'date_asked': DateTime.now().toIso8601String(),
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
      setState(() => _errorMessage = 'Selectează un document și întrebare.');
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
        ..fields['language'] = _selectedLanguage;
      final response = await http.Response.fromStream(await req.send());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _backendResponse =
              'Răspuns: ${data["answer"]}\nLocație: ${data["location"]}';
        });
        await _saveDocumentRecord(data["answer"]);
      } else {
        setState(() => _errorMessage =
            'Server error ${response.statusCode}: ${response.body}');
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
    // Paletă cromatică plăcută
    const accents = [
      Color(0xFF4A90E2), // albastru
      Color(0xFF50E3C2), // teal
      Color(0xFFF5A623), // amber
      Color(0xFF9013FE), // violet
    ];
    final primary = accents[0];
    final secondary = accents[1];

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Încarcă Document',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Coloana stângă ─────────────────────────
              Flexible(
                flex: 2,
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _SectionCard(
                        icon: Icons.insert_drive_file,
                        iconColor: primary,
                        title: 'Document',
                        subtitle: _documentPath == null
                            ? 'Niciun document selectat'
                            : _documentPath!
                                .split(Platform.pathSeparator)
                                .last,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: Text(_documentPath == null
                              ? 'Selectează'
                              : 'Schimbă'),
                          style: buttonStyle,
                          onPressed: _pickDocument,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _SectionCard(
                        icon: Icons.language,
                        iconColor: secondary,
                        title: 'Limba documentului',
                        child: DropdownButtonFormField<String>(
                          value: _selectedLanguage,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: secondary.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ro', child: Text('Română')),
                            DropdownMenuItem(value: 'en', child: Text('Engleză')),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedLanguage = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: _SectionCard(
                        icon: Icons.question_answer,
                        iconColor: primary,
                        title: 'Întrebarea ta',
                        child: TextField(
                          controller: _questionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Scrie întrebarea aici...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            border: Border.all(color: Colors.redAccent),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(_errorMessage,
                                    style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w600)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ElevatedButton.icon(
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.cloud_upload),
                        label: Text(
                            _isLoading ? 'Încarcă...' : 'Generează răspuns'),
                        style: buttonStyle,
                        onPressed: _isLoading ? null : _uploadDocument,
                      ),
                    ),
                    if (_backendResponse.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child:
                            ResponseCard(responseText: _backendResponse),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // ─── Coloana dreaptă ─────────────────────────
              Flexible(
                flex: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    children: [
                      // Ilustrație
                      Opacity(
                        opacity: 0.2,
                        child: Image.asset(
                          'assets/images/document_illustration.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Pași numerotați „Cum funcționează?”
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Cum funcționează?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: secondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Lista de pași
                              ...[
                                'Selectează un PDF sau DOC de pe device.',
                                'Introdu întrebarea în câmpul dedicat.',
                                'Apasă butonul „Generează răspuns”.',
                              ].asMap().entries.map((entry) {
                                final step = entry.key + 1;
                                final text = entry.value;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: secondary,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$step',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          text,
                                          style: const TextStyle(
                                              fontSize: 14, height: 1.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget reutilizabil pentru secțiuni cu header, subtitlu și conținut
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: iconColor.withOpacity(0.4),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: iconColor)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black54)),
                  ]
                ],
              ),
            ]),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
