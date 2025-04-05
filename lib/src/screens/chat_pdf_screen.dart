import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ChatWithPdfScreen extends StatefulWidget {
  const ChatWithPdfScreen({Key? key}) : super(key: key);

  @override
  State<ChatWithPdfScreen> createState() => _ChatWithPdfScreenState();
}

class _ChatWithPdfScreenState extends State<ChatWithPdfScreen> {
  // Stocăm căile PDF-urilor încărcate sau doar un singur PDF
  String? _pdfPath;

  // Listă de mesaje (user & chatbot)
  List<_ChatMessage> _messages = [];

  // Controller pentru câmpul de text (pentru întrebări)
  final TextEditingController _questionController = TextEditingController();

  bool _isLoading = false;

  // Funcție pentru a alege fișierul PDF
  Future<void> _pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pdfPath = result.files.single.path;
      });
      // Aici poți apela un endpoint sau o metodă pentru a procesa PDF-ul
      // ex. upload la backend, stocare locală etc.
    }
  }

  // Funcție pentru a trimite întrebarea către un "backend" (sau local, de ex.)
  Future<void> _sendQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
      // Adăugăm întrebarea în listă
      _messages.add(_ChatMessage(text: question, isUser: true));
    });

    // Simulăm un răspuns din partea "chatbotului"
    // În practică, apelezi un endpoint care procesează PDF-ul + întrebare
    await Future.delayed(const Duration(seconds: 1));
    final fakeAnswer = "Răspunsul simulant la întrebarea: $question\n\n(Exemplu)";

    setState(() {
      _isLoading = false;
      _messages.add(_ChatMessage(text: fakeAnswer, isUser: false));
      _questionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with your PDF"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Row(
        children: [
          // Panou lateral pentru încărcarea PDF-ului
          Container(
            width: 300,
            color: Colors.grey[200],
            child: _buildPdfPanel(context),
          ),
          // Spațiul principal de chat
          Expanded(
            child: Column(
              children: [
                // Lista de mesaje
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _buildChatBubble(msg);
                    },
                  ),
                ),
                // Câmpul de introducere a întrebărilor
                _buildQuestionInput(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Panou pentru PDF
  Widget _buildPdfPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Upload Your PDF File",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickPdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text("Browse files"),
          ),
          const SizedBox(height: 16),
          if (_pdfPath != null)
            Text(
              "Selected PDF:\n$_pdfPath",
              style: const TextStyle(fontSize: 14),
            ),
        ],
      ),
    );
  }

  // Câmpul de text + butonul de trimitere
  Widget _buildQuestionInput(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                hintText: "Enter your question...",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendQuestion(),
            ),
          ),
          const SizedBox(width: 8),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _sendQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  child: const Text("Send"),
                ),
        ],
      ),
    );
  }

  // Bubble pentru mesaje
  Widget _buildChatBubble(_ChatMessage msg) {
    final alignment = msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = msg.isUser ? Colors.deepPurple[100] : Colors.grey[300];
    final textColor = msg.isUser ? Colors.black87 : Colors.black87;
    final radius = msg.isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
            ),
            child: Text(
              msg.text,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

// Model simplu pentru un mesaj de chat
class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
