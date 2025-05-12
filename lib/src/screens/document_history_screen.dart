// lib/src/screens/document_history_screen.dart

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
  late Future<List<DocumentRecord>> _futureRecords;

  // ─── Local filters & sort ─────────────────────────────────────────────
  String _langFilter = 'All';      // All | ro | en
  DateTimeRange? _dateRange;       // date interval
  bool _sortDescending = true;     // desc vs asc
  String _searchQuery = '';        // question search text

  @override
  void initState() {
    super.initState();
    _futureRecords = _fetchAllRecords();
  }

  Future<List<DocumentRecord>> _fetchAllRecords() async {
    final token = AuthService.token;
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse('http://127.0.0.1:5000/document_records');
    final res = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (res.statusCode != 200) {
      throw Exception('Failed to load records: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = data['document_records'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(DocumentRecord.fromJson)
        .toList();
  }

  // ─── UI builders ──────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF26A69A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Istoric Documente & Întrebări',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Caută întrebare…',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
        ),
        onChanged: (v) => setState(() => _searchQuery = v.trim()),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          // Language dropdown
          DropdownButton<String>(
            value: _langFilter,
            items: const [
              DropdownMenuItem(value: 'All', child: Text('Toate limbile')),
              DropdownMenuItem(value: 'ro', child: Text('Română')),
              DropdownMenuItem(value: 'en', child: Text('Engleză')),
            ],
            onChanged: (v) => setState(() => _langFilter = v!),
          ),

          // Date range picker
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              _dateRange == null
                  ? 'Toate datele'
                  : '${_dateRange!.start.toIso8601String().split('T').first}'
                    ' – '
                    '${_dateRange!.end.toIso8601String().split('T').first}',
            ),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _dateRange = picked);
            },
          ),

          // Clear date range
          if (_dateRange != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Șterge intervalul',
              onPressed: () => setState(() => _dateRange = null),
            ),

          // Sort toggle
          IconButton(
            icon: Icon(
              _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
            ),
            tooltip: 'Sortare după dată',
            onPressed: () =>
                setState(() => _sortDescending = !_sortDescending),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<DocumentRecord> docs) {
    if (docs.isEmpty) {
      return const Center(child: Text('Nu există înregistrări.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: docs.length,
      itemBuilder: (ctx, i) {
        final doc = docs[i];

        // Apply question‐level filters
        final visibleQs = doc.questions.where((q) {
          final matchLang = _langFilter == 'All' ||
              q.language.toLowerCase() == _langFilter;
          final matchSearch = _searchQuery.isEmpty ||
              q.question.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchLang && matchSearch;
        }).toList();

        if (visibleQs.isEmpty) return const SizedBox.shrink();

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child:
                  const Icon(Icons.description, color: Colors.teal, size: 28),
            ),
            title: Text(
              doc.document.title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Încărcat: ${doc.document.dateUploaded}'),
            children: visibleQs.map((q) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(q.question,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Răspuns: ${q.answer}\n'
                    'Data: ${q.dateAsked}\n'
                    'Limba: ${q.language}',
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ─── build() ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildAppBar(),
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: FutureBuilder<List<DocumentRecord>>(
              future: _futureRecords,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Eroare: ${snap.error}'));
                }

                // 1️⃣ original list
                var docs = snap.data!;

                // 2️⃣ date‐range filter
                if (_dateRange != null) {
                  docs = docs.where((d) {
                    final dt = DateTime.parse(d.document.dateUploaded);
                    return !dt.isBefore(_dateRange!.start) &&
                        !dt.isAfter(_dateRange!.end);
                  }).toList();
                }

                // 3️⃣ sort by upload date
                docs.sort((a, b) {
                  final da = DateTime.parse(a.document.dateUploaded);
                  final db = DateTime.parse(b.document.dateUploaded);
                  return _sortDescending ? db.compareTo(da) : da.compareTo(db);
                });

                // 4️⃣ build filtered & sorted list
                return _buildList(docs);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Models ───────────────────────────────────────────────────────────────

class DocumentRecord {
  final DocumentInfo document;
  final List<QuestionRecord> questions;
  DocumentRecord({required this.document, required this.questions});

  factory DocumentRecord.fromJson(Map<String, dynamic> json) {
    final docJson = json['document'] as Map<String, dynamic>? ?? {};
    final qsJson = json['questions'] as List<dynamic>? ?? [];
    return DocumentRecord(
      document: DocumentInfo.fromJson(docJson),
      questions: qsJson
          .whereType<Map<String, dynamic>>()
          .map(QuestionRecord.fromJson)
          .toList(),
    );
  }
}

class DocumentInfo {
  final int id;
  final String title;
  final String dateUploaded;
  DocumentInfo({
    required this.id,
    required this.title,
    required this.dateUploaded,
  });
  factory DocumentInfo.fromJson(Map<String, dynamic> json) => DocumentInfo(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        dateUploaded: json['date_uploaded'] as String? ?? '',
      );
}

class QuestionRecord {
  final String question;
  final String answer;
  final String dateAsked;
  final String language;
  QuestionRecord({
    required this.question,
    required this.answer,
    required this.dateAsked,
    required this.language,
  });
  factory QuestionRecord.fromJson(Map<String, dynamic> json) =>
      QuestionRecord(
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        dateAsked: json['date_asked'] as String? ?? '',
        language: json['language'] as String? ?? 'ro',
      );
}
