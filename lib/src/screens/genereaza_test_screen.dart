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

  String? get _token => AuthService.token;

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _documentPath = result.files.single.path);
    }
  }

  Future<void> _generateTest() async {
    if (_documentPath == null || _numQuestionsController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Selectează un document și numărul de întrebări.';
      });
      return;
    }
    if (_token == null) {
      setState(() {
        _errorMessage = 'Te rugăm să te autentifici.';
      });
      return;
    }

    final int numQ = int.tryParse(_numQuestionsController.text) ?? 3;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _generatedQuestions.clear();
    });

    try {
      final uri = Uri.parse('http://127.0.0.1:5000/generate_test');
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $_token'
        ..fields['num_questions'] = numQ.toString()
        ..files.add(await http.MultipartFile.fromPath(
          'document',
          _documentPath!,
          contentType: MediaType('application', 'pdf'),
        ));

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data.containsKey('error')) {
          setState(() => _errorMessage = 'Backend error: ${data['error']}');
        } else if (data.containsKey('questions') && data['questions'] != null) {
          try {
            final List<String> qs = List<String>.from(data['questions']);
            setState(() => _generatedQuestions = qs);
          } catch (e) {
            setState(() => _errorMessage = 'Răspuns neașteptat: $e');
          }
        } else {
          setState(() => _errorMessage = 'Format răspuns invalid.');
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
    _numQuestionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final btnStyle = ElevatedButton.styleFrom(
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(vertical: 14),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generează Test'),
        centerTitle: true,
        elevation: 2,
        backgroundColor: cs.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card pentru încărcare document
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: Icon(
                  Icons.upload_file,
                  color: cs.primary,
                ),
                title: Text(
                  _documentPath == null
                      ? 'Selectează PDF'
                      : _documentPath!.split('/').last,
                  style: TextStyle(color: cs.onSurface),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _pickDocument,
              ),
            ),
            const SizedBox(height: 16),

            // Număr întrebări
            TextField(
              controller: _numQuestionsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Număr întrebări',
                prefixIcon: Icon(Icons.format_list_numbered, color: cs.primary),
                filled: true,
                fillColor: cs.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buton generează
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: cs.primary))
                  : ElevatedButton.icon(
                      style: btnStyle,
                      icon: const Icon(Icons.quiz),
                      label: const Text('Generează'),
                      onPressed: _generateTest,
                    ),
            ),

            const SizedBox(height: 16),

            // Mesaj eroare
            if (_errorMessage.isNotEmpty)
              Card(
                color: cs.errorContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: cs.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: cs.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Întrebări generate
            if (_generatedQuestions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Întrebări generate:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _generatedQuestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.primaryContainer,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(color: cs.onPrimaryContainer),
                        ),
                      ),
                      title: Text(
                        _generatedQuestions[i],
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
