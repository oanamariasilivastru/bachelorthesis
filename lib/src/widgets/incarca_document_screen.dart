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
  String _selectedLanguage = 'Română';
  final TextEditingController _questionController = TextEditingController();

  String _backendResponse = '';
  String _errorMessage = '';
  bool _isLoading = false;

  // Tokenul stocat după login
  String? get _token => AuthService.token;

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _documentPath = result.files.single.path;
      });
    }
  }

  Future<void> _saveDocumentRecord(String answer) async {
    final url = Uri.parse('http://127.0.0.1:5000/save_document_record');
    // Folosim numele fișierului ca titlu (poți adapta după necesitate)
    final String title = _documentPath?.split(Platform.pathSeparator).last ?? 'Document';
    final recordData = {
      'title': title,
      'file_path': _documentPath,
      'date_uploaded': DateTime.now().toIso8601String(),
      'question': _questionController.text,
      'answer': answer,
      'date_asked': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(recordData),
      );

      if (response.statusCode != 201) {
        print("Error saving document record: ${response.body}");
      } else {
        print("Document record saved successfully.");
      }
    } catch (e) {
      print("Exception saving document record: $e");
    }
  }

  Future<void> _uploadDocument() async {
    if (_documentPath == null || _questionController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Selectează un document și introdu o întrebare.';
      });
      return;
    }
    if (_token == null) {
      setState(() {
        _errorMessage = 'Nu ești autentificat. Te rugăm să te loghezi.';
      });
      return;
    }
    setState(() {
      _errorMessage = '';
      _isLoading = true;
      _backendResponse = '';
    });

    try {
      var uri = Uri.parse('http://127.0.0.1:5000/process_pdf');
      var request = http.MultipartRequest('POST', uri);

      // Adăugăm tokenul în header
      request.headers['Authorization'] = 'Bearer $_token';

      // Atașăm fișierul
      request.files.add(await http.MultipartFile.fromPath(
        'document',
        _documentPath!,
        contentType: MediaType('application', 'pdf'),
      ));

      // Adăugăm câmpurile formularului
      request.fields['question'] = _questionController.text;
      request.fields['language'] = _selectedLanguage;

      // Trimitem request-ul
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _backendResponse = 'Răspuns: ${data["answer"]}\nLocație: ${data["location"]}';
        });
        // Salvează înregistrarea documentului
        await _saveDocumentRecord(data["answer"]);
      } else {
        setState(() {
          _errorMessage = 'Eroare de la backend: ${response.statusCode}, ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Eroare: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle commonButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Încarcă document", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Încarcă un document și pune o întrebare:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.file_upload_outlined, color: Colors.deepPurple, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _documentPath ?? "Niciun document selectat",
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickDocument,
                      style: commonButtonStyle,
                      child: const Text("Selectează"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.language_outlined, color: Colors.orangeAccent, size: 32),
                    const SizedBox(width: 16),
                    const Text(
                      "Limba documentului:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                      items: const [
                        DropdownMenuItem(value: 'Română', child: Text('Română', style: TextStyle(fontSize: 16))),
                        DropdownMenuItem(value: 'Engleză', child: Text('Engleză', style: TextStyle(fontSize: 16))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    labelText: "Introdu întrebarea",
                    labelStyle: const TextStyle(fontSize: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.question_answer, color: Colors.deepPurple),
                  ),
                  minLines: 1,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(fontSize: 16, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.deepPurple)
                  : ElevatedButton.icon(
                      onPressed: _uploadDocument,
                      style: commonButtonStyle,
                      icon: const Icon(Icons.cloud_upload_outlined, size: 28),
                      label: const Text('Generează răspuns', style: TextStyle(fontSize: 16)),
                    ),
            ),
            const SizedBox(height: 20),
            ResponseCard(responseText: _backendResponse),
          ],
        ),
      ),
    );
  }
}
