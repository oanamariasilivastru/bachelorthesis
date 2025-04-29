// lib/src/screens/quiz_session_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/src/models/quiz_item.dart';

class QuizSessionScreen extends StatefulWidget {
  final List<QuizItem> items;
  final int timerSeconds;
  final String language;

  const QuizSessionScreen({
    Key? key,
    required this.items,
    required this.language,
    this.timerSeconds = 300,
  }) : super(key: key);

  @override
  _QuizSessionScreenState createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int _current = 0;
  int? _selectedIndex;
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = widget.timerSeconds;
    if (_remaining > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_remaining > 0) {
          setState(() => _remaining--);
        } else {
          t.cancel();
        }
      });
    }
  }

  void _selectAnswer(int idx) {
    if (_selectedIndex == null && _remaining > 0) {
      setState(() => _selectedIndex = idx);
    }
  }

  void _nextQuestion() {
    if (_current < widget.items.length - 1) {
      setState(() {
        _current++;
        _selectedIndex = null;
      });
      _startTimer();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_current];
    final cs = Theme.of(context).colorScheme;
    final title = widget.language == 'ro'
        ? 'Întrebarea ${_current + 1}/${widget.items.length}'
        : 'Question ${_current + 1}/${widget.items.length}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: cs.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (widget.timerSeconds > 0) ...[
              LinearProgressIndicator(
                value: _remaining / widget.timerSeconds,
                minHeight: 8,
                backgroundColor: cs.primary.withOpacity(0.3),
                color: cs.primary,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.language == 'ro'
                      ? 'Timp rămas: $_remaining s'
                      : 'Time left: $_remaining s',
                  style: TextStyle(color: cs.onBackground),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              item.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...item.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final opt = entry.value;
              Color bg;
              if (_selectedIndex == null) {
                bg = cs.surface;
              } else if (idx == _selectedIndex) {
                bg = opt == item.answer
                    ? Colors.greenAccent.shade100
                    : Colors.redAccent.shade100;
              } else if (opt == item.answer) {
                bg = Colors.greenAccent.shade100;
              } else {
                bg = cs.surface;
              }
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: cs.onSurface,
                    backgroundColor: bg,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () => _selectAnswer(idx),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(opt, style: const TextStyle(fontSize: 16)),
                  ),
                ),
              );
            }).toList(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _nextQuestion,
                child: Text(
                  widget.language == 'ro'
                      ? (_current < widget.items.length - 1
                          ? 'Următoarea întrebare'
                          : 'Finalizează quiz')
                      : (_current < widget.items.length - 1
                          ? 'Next question'
                          : 'Finish quiz'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
