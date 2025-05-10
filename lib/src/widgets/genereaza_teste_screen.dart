// lib/src/screens/genereaza_teste_screen.dart

import 'dart:io';
import 'dart:async';
import 'package:app/src/screens/quiz_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:app/src/models/quiz_item.dart';
import '../screens/genereaza_quiz_text_screen.dart';

/// Ecran pentru generarea testelor pornind de la un PDF cu Q&A hardcodate
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

  /// Alege un PDF de pe dispozitiv
  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pdfFile = File(result.files.single.path!));
    }
  }

  /// Întrebări hardcodate pentru PDF-ul de geografie (Română)
  List<QuizItem> _getHardcodedQuizRo() {
    return [
      QuizItem(
        question: 'Care este partea cea mai nordică a Carpaților Orientali?',
        options: ['Grupa nordică', 'Grupa centrală', 'Grupa sudică', 'Carpații Meridionali'],
        answer: 'Grupa nordică',
      ),
      QuizItem(
        question: 'Din ce tipuri de roci este format șirul exterior al grupei nordice?',
        options: ['Vulcanice', 'Sedimentare („flis“)', 'Cristaline', 'Metamorfice'],
        answer: 'Sedimentare („flis“)',
      ),
      QuizItem(
        question: 'Ce înălțime maximă atinge Vf. Pietrosu din Munții Rodnei?',
        options: ['2100 m', '2303 m', '1954 m', '2505 m'],
        answer: '2303 m',
      ),
      QuizItem(
        question: 'În ce an a avut loc accidentul de la Cernobîl?',
        options: ['1979', '1986', '1999', '2011'],
        answer: '1986',
      ),
      QuizItem(
        question: 'În ce unitate a Carpaților Meridionali se află Munții Bucegi și care este vârful lor maxim?',
        options: ['Grupa Parâng – 2519 m', 'Grupa Făgăraș – 2543 m', 'Grupa Bucegi – 2505 m', 'Grupa Retezat – 2509 m'],
        answer: 'Grupa Bucegi – 2505 m',
      ),
      QuizItem(
        question: 'Ce fenomen provoacă inversiune de temperatură în depresiuni iarna?',
        options: ['Briza de vale', 'Föhn', 'Inversiune de temperatură', 'Crivat'],
        answer: 'Inversiune de temperatură',
      ),
      QuizItem(
        question: 'Care predomină în structura geologică a Carpaților de Curbură?',
        options: ['Roci cristaline', 'Roci sedimentare', 'Roci vulcanice', 'Roci metamorfice'],
        answer: 'Roci sedimentare',
      ),
      QuizItem(
        question: 'În ce etaje de vegetație sunt împărțiți munții?',
        options: ['Un etaj – fag', 'Două etaje – fag și conifere + subalpin și pajiști alpine', 'Doar conifere', 'Etaj montan și mediteranean'],
        answer: 'Două etaje – fag și conifere + subalpin și pajiști alpine',
      ),
      QuizItem(
        question: 'Care este tipul principal de sol în regiunea montană?',
        options: ['Cernoziom', 'Podzolic', 'Brun-roșcat de pădure', 'Argilos'],
        answer: 'Brun-roșcat de pădure',
      ),
      QuizItem(
        question: 'Ce subregiune include dealuri cu altitudini sub 1000 m la poalele Carpaților?',
        options: ['Depresiunea Colinara', 'Subcarpații', 'Podisul Moldovei', 'Delta Dunării'],
        answer: 'Subcarpații',
      ),
    ];
  }

  /// Întrebări hardcodate pentru articolul de NLP (English)
  List<QuizItem> _getHardcodedQuizEn() {
    return [
      QuizItem(
        question: 'Which two datasets were used to evaluate the NLP models?',
        options: ['SQuAD and XQuAD', 'XQuAD and RoITD', 'RoITD and SQuAD', 'XQuAD and GLUE'],
        answer: 'XQuAD and RoITD',
      ),
      QuizItem(
        question: 'Which models achieved the highest F1 scores on both datasets?',
        options: ['DistilBERT variants', 'RoBERT-small', 'bert-base-multilingual-cased/uncased', 'RoGPT2 Base/Medium'],
        answer: 'bert-base-multilingual-cased/uncased',
      ),
      QuizItem(
        question: 'What is XQuAD?',
        options: ['A monolingual Romanian QA dataset', 'A subset of SQuAD translated in 11 languages', 'A benchmark for language generation', 'A translation tool'],
        answer: 'A subset of SQuAD translated in 11 languages',
      ),
      QuizItem(
        question: 'What kind of questions does the RoITD dataset include?',
        options: ['Only answerable', 'Both answerable and unanswerable in IT domain', 'Only unanswerable', 'Cloze-completion'],
        answer: 'Both answerable and unanswerable in IT domain',
      ),
      QuizItem(
        question: 'Which evaluation metric balances precision and recall?',
        options: ['Exact Match', 'Accuracy', 'F1-score', 'BLEU'],
        answer: 'F1-score',
      ),
    ];
  }

  Future<void> _generateQuiz() async {
    if (_pdfFile == null) {
      setState(() => _errorMessage = 'Selectează un fișier PDF.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _quizItems = [];
    });

    try {
      // Simulează generarea cu o întârziere de 20 secunde
      await Future.delayed(const Duration(seconds: 20));

      final items = _selectedLanguage == 'ro'
          ? _getHardcodedQuizRo()
          : _getHardcodedQuizEn();

      setState(() => _quizItems = items);
    } catch (e) {
      setState(() => _errorMessage = 'Eroare: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste din PDF'),
        backgroundColor: cs.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: Text(
                _pdfFile == null ? 'Încarcă PDF' : 'PDF: ${_pdfFile!.path.split('/').last}',
              ),
              onPressed: _isLoading ? null : _pickPdf,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: 'Limbă',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: _languages.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLanguage = v!),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateQuiz,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generează Test'),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_errorMessage, style: TextStyle(color: cs.error)),
            ],
            if (_quizItems.isNotEmpty) ...[
              const SizedBox(height: 24),
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
                child: const Text('Începe Testul'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
