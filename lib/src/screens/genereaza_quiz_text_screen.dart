import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app/src/services/api_service.dart';
import 'package:app/src/services/auth_service.dart';

class GenereazaQuizTextScreen extends StatefulWidget {
  const GenereazaQuizTextScreen({Key? key}) : super(key: key);

  @override
  State<GenereazaQuizTextScreen> createState() =>
      _GenereazaQuizTextScreenState();
}

class _GenereazaQuizTextScreenState extends State<GenereazaQuizTextScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _numQController =
      TextEditingController(text: '3');
  bool _isLoading = false;
  String _errorMessage = '';
  List<String> _questions = [];

  final ApiService _api = ApiService();

  String? get _token => AuthService.token;

  Future<void> _generateQuiz() async {
    final text = _textController.text.trim();
    final numQ = int.tryParse(_numQController.text) ?? 3;

    if (text.isEmpty) {
      setState(() =>
          _errorMessage = 'Introdu textul de la care să generezi quiz.');
      return;
    }
    if (_token == null) {
      setState(() => _errorMessage = 'Te rugăm să te autentifici.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _questions.clear();
    });

    try {
      final response = await _api.generateQuizFromText(
        token: _token!,
        text: text,
        numQuestions: numQ,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data.containsKey('error')) {
          setState(() => _errorMessage = data['error']);
        } else if (data.containsKey('questions')) {
          setState(() =>
              _questions = List<String>.from(data['questions'] as List));
        } else {
          setState(() => _errorMessage = 'Răspuns neașteptat de la server.');
        }
      } else {
        setState(() => _errorMessage =
            'Eroare ${response.statusCode}: ${response.body}');
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
        backgroundColor: cs.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input multi-line pentru textul sursă
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Li​pește aici textul sursă...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            // Număr întrebări
            TextField(
              controller: _numQController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Număr întrebări',
                prefixIcon:
                    Icon(Icons.format_list_numbered, color: cs.secondary),
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
                  ? Center(child: CircularProgressIndicator(color: cs.secondary))
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.quiz),
                      label: const Text('Generează Quiz'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.secondary,
                        foregroundColor: cs.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _generateQuiz,
                    ),
            ),
            const SizedBox(height: 16),
            // Mesaj de eroare
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: TextStyle(color: cs.error)),
            // Listă întrebări generate
            if (_questions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Întrebări generate:',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: _questions.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.secondaryContainer,
                        child: Text(
                          '${index + 1}',
                          style:
                              TextStyle(color: cs.onSecondaryContainer),
                        ),
                      ),
                      title: Text(_questions[index]),
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
