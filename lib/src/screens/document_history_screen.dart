import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class DocumentHistoryScreen extends StatefulWidget {
  const DocumentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DocumentHistoryScreen> createState() => _DocumentHistoryScreenState();
}

class _DocumentHistoryScreenState extends State<DocumentHistoryScreen> {
  Future<List<DocumentRecord>>? _futureRecords;

  @override
  void initState() {
    super.initState();
    _futureRecords = _fetchDocumentRecords();
  }

  Future<List<DocumentRecord>> _fetchDocumentRecords() async {
    final token = AuthService.token;
    if (token == null) {
      throw Exception("Not authenticated");
    }
    final url = Uri.parse('http://127.0.0.1:5000/document_records');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final recordsJson = data['document_records'] as List;
      return recordsJson
          .map((json) => DocumentRecord.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to load records: ${response.body}");
    }
  }

  // Header personalizat cu buton de back
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              "Istoric documente și întrebări",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 40), // Spacer pentru centrare
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FutureBuilder<List<DocumentRecord>>(
              future: _futureRecords,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                } else if (snapshot.hasError) {
                  return Center(child: Text("Eroare: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nu există înregistrări"));
                } else {
                  final records = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          leading: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: const Icon(
                              Icons.description,
                              color: Colors.deepPurple,
                            ),
                          ),
                          title: Text(
                            record.document.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text("Data: ${record.document.dateUploaded}"),
                          children: record.questions.map((q) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(q.question, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text("Răspuns: ${q.answer}\nData: ${q.dateAsked}"),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Modelele de date:
class DocumentRecord {
  final Document document;
  final List<QuestionRecord> questions;
  DocumentRecord({required this.document, required this.questions});

  factory DocumentRecord.fromJson(Map<String, dynamic> json) {
    var docJson = json['document'];
    var questionsJson = json['questions'] as List;
    return DocumentRecord(
      document: Document.fromJson(docJson),
      questions: questionsJson.map((q) => QuestionRecord.fromJson(q)).toList(),
    );
  }
}

class Document {
  final int id;
  final String filePath;
  final String title;
  final String dateUploaded;
  Document({
    required this.id,
    required this.filePath,
    required this.title,
    required this.dateUploaded,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      filePath: json['file_path'],
      title: json['title'] ?? '',
      dateUploaded: json['date_uploaded'],
    );
  }
}

class QuestionRecord {
  final String question;
  final String answer;
  final String dateAsked;
  QuestionRecord({
    required this.question,
    required this.answer,
    required this.dateAsked,
  });

  factory QuestionRecord.fromJson(Map<String, dynamic> json) {
    return QuestionRecord(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      dateAsked: json['date_asked'] ?? '',
    );
  }
}
