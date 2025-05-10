// lib/src/screens/genereaza_quiz_text_screen.dart

import 'package:flutter/material.dart';
import 'package:app/src/models/quiz_item.dart';
import 'quiz_session_screen.dart';

class GenereazaQuizTextScreen extends StatefulWidget {
  const GenereazaQuizTextScreen({Key? key}) : super(key: key);

  @override
  State<GenereazaQuizTextScreen> createState() => _GenereazaQuizTextScreenState();
}

class _GenereazaQuizTextScreenState extends State<GenereazaQuizTextScreen> {
  final _textController = TextEditingController();
  final _numQController = TextEditingController(text: '10');
  bool _isLoading = false;
  String _errorMessage = '';
  List<QuizItem> _quizItems = [];
  int _timerSeconds = 60;

  static const Map<String, String> _languages = {
    'ro': 'Română',
    'en': 'English',
  };
  String _selectedLanguage = 'ro';

  /// Returnează întrebări hardcodate pentru fiecare limbă
  List<QuizItem> _getHardcodedQuizItems(String lang, int count) {
    if (lang == 'ro') {
      final all = <QuizItem>[
        QuizItem(
          question: 'Ce tip de reacție nucleară este cel mai des folosit în centralele nucleare actuale?',
          options: ['Fuziunea nucleară', 'Fisiunea nucleară', 'Descompunerea radioactivă', 'Combustia nucleară'],
          answer: 'Fisiunea nucleară',
        ),
        QuizItem(
          question: 'Ce element este cel mai frecvent utilizat ca combustibil nuclear?',
          options: ['Carbon-14', 'Hidrogen-2', 'Uraniul-235', 'Plumb-208'],
          answer: 'Uraniul-235',
        ),
        QuizItem(
          question: 'Care este principalul avantaj al energiei nucleare în contextul schimbărilor climatice?',
          options: ['Producerea rapidă a energiei', 'Absența emisiilor de dioxid de carbon', 'Costul scăzut al construcției', 'Utilizarea oxigenului ca combustibil'],
          answer: 'Absența emisiilor de dioxid de carbon',
        ),
        QuizItem(
          question: 'În ce an a avut loc accidentul nuclear de la Cernobîl?',
          options: ['1986', '1979', '2011', '1999'],
          answer: '1986',
        ),
        QuizItem(
          question: 'Care este una dintre metodele principale de stocare a deșeurilor radioactive?',
          options: ['Depozitarea subterană în formațiuni geologice stabile', 'Arderea lor în cuptoare speciale', 'Vânzarea ca îngrășământ', 'Eliberarea în atmosferă'],
          answer: 'Depozitarea subterană în formațiuni geologice stabile',
        ),
        QuizItem(
          question: 'Ce organizație supraveghează activitățile nucleare ale statelor membre?',
          options: ['AIEA', 'NATO', 'ONU', 'OMC'],
          answer: 'AIEA',
        ),
        QuizItem(
          question: 'Care este o problemă de securitate asociată energiei nucleare?',
          options: ['Proliferarea armelor nucleare', 'Poluarea fonică', 'Defrișările masive', 'Creșterea nivelului de oxigen'],
          answer: 'Proliferarea armelor nucleare',
        ),
        QuizItem(
          question: 'Ce reacție nucleară ar putea oferi mai puține deșeuri radioactive și riscuri reduse de accidente majore?',
          options: ['Fuziunea nucleară', 'Fisiunea nucleară', 'Descompunerea radioactivă', 'Combustia nucleară'],
          answer: 'Fuziunea nucleară',
        ),
        QuizItem(
          question: 'Ce se produce în urma fisiunii nucleare, pe lângă energia termică?',
          options: ['Neutroni liberi și produse de fisiune', 'Oxigen și apă', 'Dioxid de carbon și vapori', 'Laser și electroni'],
          answer: 'Neutroni liberi și produse de fisiune',
        ),
        QuizItem(
          question: 'De ce este importantă izolarea deșeurilor radioactive pentru perioade îndelungate?',
          options: ['Pot rămâne periculoase mii de ani', 'Trebuie transformate în energie', 'Îmbunătățesc clima', 'Devine îngrășământ'],
          answer: 'Pot rămâne periculoase mii de ani',
        ),
      ];
      return all.take(count).toList();
    } else {
      final all = <QuizItem>[
        QuizItem(
          question: 'Into how many main branches are the Carpathian Mountains divided?',
          options: ['2', '3', '4', '5'],
          answer: '3',
        ),
        QuizItem(
          question: 'Which three units compose the Eastern Carpathians?',
          options: [
            'Northern, Central, Curvature',
            'Transylvanian, Banat, Getic',
            'Maramureș, Făgăraș, Apuseni',
            'Bucegi, Retezat, Parâng'
          ],
          answer: 'Northern, Central, Curvature',
        ),
        QuizItem(
          question: 'What plateau borders the Northern Eastern Carpathians to the west?',
          options: [
            'Moldavian Plateau',
            'Transylvanian Plateau',
            'Wallachian Plain',
            'Danubian Plain'
          ],
          answer: 'Transylvanian Plateau',
        ),
        QuizItem(
          question: 'What are the three parallel ridges of the Northern Eastern Carpathians?',
          options: [
            'Flysch, crystalline, volcanic',
            'Limestone, marble, basalt',
            'Sedimentary, metamorphic, igneous',
            'Dolomite, quartzite, gneiss'
          ],
          answer: 'Flysch, crystalline, volcanic',
        ),
        QuizItem(
          question: 'What is the highest peak of the Northern Eastern Carpathians and its elevation?',
          options: [
            'Ciucaș – 1,954 m',
            'Omu – 2,505 m',
            'Pietrosu Rodnei – 2,303 m',
            'Moldoveanu – 2,543 m'
          ],
          answer: 'Pietrosu Rodnei – 2,303 m',
        ),
        QuizItem(
          question: 'Which gorge is highlighted in the Central Eastern Carpathians?',
          options: ['Bicaz Gorge', 'Turda Gorge', 'Iron Gates Defile', 'Cheile Nerei'],
          answer: 'Bicaz Gorge',
        ),
        QuizItem(
          question:
              'What is the maximum summit height in the Curvature Carpathians (Southern Eastern Carpathians)?',
          options: ['1,800 m', '1,954 m', '2,303 m', '2,505 m'],
          answer: '1,954 m',
        ),
        QuizItem(
          question:
              'Which massifs form Romania’s highest peaks in the Southern Carpathians?',
          options: [
            'Apuseni and Banat',
            'Bucegi, Făgăraș, Parâng, Retezat–Godeanu',
            'Maramureș–Bucovina and Moldavian–Transylvanian',
            'Călimani and Harghita'
          ],
          answer: 'Bucegi, Făgăraș, Parâng, Retezat–Godeanu',
        ),
        QuizItem(
          question: 'Which river does not originate in the Carpathians?',
          options: ['Olt', 'Someș', 'Danube', 'Bistrița'],
          answer: 'Danube',
        ),
        QuizItem(
          question:
              'Approximately how much precipitation do the Carpathians receive annually at altitude?',
          options: [
            'Less than 500 mm',
            'Around 700 mm',
            'Over 1,000 mm',
            'Over 1,500 mm'
          ],
          answer: 'Over 1,000 mm',
        ),
      ];
      return all.take(count).toList();
    }
  }

  Future<void> _generateQuiz() async {
    final text = _textController.text.trim();
    final numQ = int.tryParse(_numQController.text) ?? 10;

    if (text.isEmpty) {
      setState(() => _errorMessage = 'Introdu textul sursă.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _quizItems = [];
    });

    // Simulează generarea cu o întârziere de 20 secunde
    await Future.delayed(const Duration(seconds: 20));

    final items = _getHardcodedQuizItems(_selectedLanguage, numQ);
    setState(() {
      _quizItems = items;
      _isLoading = false;
    });
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
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _textController,
                  maxLines: 6,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Li​pește aici textul sursă...',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _numQController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nr. întrebări',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      labelText: 'Limbă',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _languages.entries
                        .map((e) =>
                            DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedLanguage = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Timer:'),
                Expanded(
                  child: Slider(
                    value: _timerSeconds.toDouble(),
                    min: 0,
                    max: 300,
                    divisions: 30,
                    label:
                        _timerSeconds == 0 ? 'Fără timp' : '$_timerSeconds s',
                    onChanged: (v) => setState(() => _timerSeconds = v.round()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Generează Quiz'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isLoading ? null : _generateQuiz,
              ),
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_errorMessage, style: TextStyle(color: cs.error)),
            ],
            if (_quizItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                color: cs.secondaryContainer,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Quiz-ul este gata! Ai ${_quizItems.length} întrebări.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onSecondaryContainer),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: cs.onSecondaryContainer),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
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
                          child: const Text('Începe Quiz-ul'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
