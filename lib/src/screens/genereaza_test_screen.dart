import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../services/auth_service.dart';

class GenereazaTesteScreen extends StatefulWidget {
  const GenereazaTesteScreen({Key? key}) : super(key: key);

  @override
  State<GenereazaTesteScreen> createState() => _GenereazaTesteScreenState();
}

class _GenereazaTesteScreenState extends State<GenereazaTesteScreen> {
  String? _documentPath;
  final TextEditingController _numQuestionsController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  List<String> _generatedQuestions = [];

  // Preluăm token-ul din AuthService (unde l-ai stocat după login).
  String? get _token => AuthService.token;

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _documentPath = result.files.single.path;
      });
    }
  }

  Future<void> _generateTest() async {
    if (_documentPath == null || _numQuestionsController.text.isEmpty) {
      setState(() {
        _errorMessage =
            'Selectează un document și introdu numărul de întrebări.';
      });
      return;
    }
    if (_token == null) {
      setState(() {
        _errorMessage = 'Nu ești autentificat. Te rugăm să te loghezi.';
      });
      return;
    }

    final int numQuestions = int.tryParse(_numQuestionsController.text) ?? 3;
    setState(() {
      _errorMessage = '';
      _isLoading = true;
      _generatedQuestions = [];
    });

    try {
      // Construim request-ul către backend
      final uri = Uri.parse('http://127.0.0.1:5000/generate_test');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $_token'
        ..files.add(
          await http.MultipartFile.fromPath(
            'document',
            _documentPath!,
            contentType: MediaType('application', 'pdf'),
          ),
        )
        ..fields['num_questions'] = numQuestions.toString();

      // Trimitem request-ul
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Verificăm dacă data este un Map și conține eventual un câmp 'error'
        if (data is Map<String, dynamic>) {
          // 1) Dacă există un câmp 'error' în JSON, afișăm mesajul de eroare.
          if (data.containsKey('error')) {
            setState(() {
              _errorMessage = 'Eroare de la backend: ${data["error"]}';
            });
          }
          // 2) Dacă există un câmp 'questions' și nu este null, îl convertim la listă de String.
          else if (data.containsKey('questions') && data['questions'] != null) {
            try {
              final List<String> questions =
                  List<String>.from(data['questions']);
              setState(() {
                _generatedQuestions = questions;
              });
            } catch (e) {
              setState(() {
                _errorMessage =
                    'Formatul răspunsului nu este cel așteptat. Detalii: $e';
              });
            }
          }
          // 3) Altfel, formatul de răspuns e necunoscut (lipsesc cheile așteptate).
          else {
            setState(() {
              _errorMessage =
                  'Răspuns necunoscut de la backend (lipsesc "questions").';
            });
          }
        } else {
          setState(() {
            _errorMessage =
                'Răspuns necunoscut de la backend (nu e Map<String,dynamic>).';
          });
        }
      } else {
        // Caz în care serverul răspunde cu alt cod decât 200
        setState(() {
          _errorMessage =
              'Eroare de la backend: ${response.statusCode}, ${response.body}';
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
    _numQuestionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle commonButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generează Test"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickDocument,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(_documentPath != null
                  ? "Document selectat"
                  : "Selectează Document"),
              style: commonButtonStyle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _numQuestionsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Număr de întrebări",
                prefixIcon: const Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.deepPurple)
                : ElevatedButton.icon(
                    onPressed: _generateTest,
                    icon: const Icon(Icons.quiz_outlined),
                    label: const Text("Generează Test"),
                    style: commonButtonStyle,
                  ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (_generatedQuestions.isNotEmpty)
              Card(
                color: Colors.orangeAccent.withOpacity(0.1),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _generatedQuestions
                        .map(
                          (q) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(q, style: const TextStyle(fontSize: 16)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
