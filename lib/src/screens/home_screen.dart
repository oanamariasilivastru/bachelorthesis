// lib/src/screens/home_screen.dart
// ignore_for_file: cascade_invocations

import 'package:app/src/widgets/genereaza_teste_screen.dart' show GenereazaTesteScreen;
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:app/src/models/activity.dart';
import 'package:app/src/services/api_service.dart';
import 'package:app/src/screens/profile_screen.dart';


import '../widgets/sidebar_button.dart';
import '../widgets/upcoming_activities_modal.dart';
import '../widgets/time_spent_chart.dart';
import '../widgets/incarca_document_screen.dart';
import '../screens/test_history_screen.dart';


import 'chat_pdf_screen.dart';
import 'document_history_screen.dart';
import 'genereaza_quiz_text_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<Activity>> _activities = {};
  final ApiService _api = ApiService();

  final Stopwatch _stopwatch = Stopwatch();
  Duration _accumulatedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stopwatch.start();
    _fetchActivities();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopwatch.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopwatch.stop();
      _accumulatedTime += _stopwatch.elapsed;
    } else if (state == AppLifecycleState.resumed) {
      _stopwatch
        ..reset()
        ..start();
    }
  }

  Future<void> _fetchActivities() async {
    try {
      final data = await _api.fetchActivities();
      final updated = <DateTime, List<Activity>>{};
      for (final row in data) {
        final d = DateTime.parse(row['date']);
        final key = DateTime(d.year, d.month, d.day);
        updated.putIfAbsent(key, () => []).add(
          Activity(title: row['title'], color: Color(row['color'])),
        );
      }
      setState(() {
        _activities
          ..clear()
          ..addAll(updated);
      });
    } catch (e) {
      debugPrint('Eroare la fetchActivities: $e');
    }
  }

  Future<void> _persistActivity(
      {required Activity act, required DateTime onDay}) async {
    final d = DateTime(onDay.year, onDay.month, onDay.day);
    final dateStr =
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    await _api.createActivity(
        date: dateStr, title: act.title, colorValue: act.color.value);
    setState(() {
      _activities.putIfAbsent(d, () => []).add(act);
    });
  }

  List<Activity> _forDay(DateTime d) {
    final key = DateTime(d.year, d.month, d.day);
    return _activities[key] ?? [];
  }

  void _dialogAddActivity(DateTime day) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    Color selected = Colors.blue;
    const palette = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Planifică activitate'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Data: ${day.toString().split(' ')[0]}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Titlu activitate'),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Completează titlul' : null,
                  onSaved: (v) => title = v!.trim(),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: palette
                      .map((c) => ChoiceChip(
                            label: const SizedBox.shrink(),
                            selected: selected == c,
                            onSelected: (_) => setSt(() => selected = c),
                            selectedColor: c.withOpacity(0.8),
                            backgroundColor: c.withOpacity(0.4),
                            avatar: Icon(Icons.circle, color: c, size: 18),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Anulează')),
            ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  formKey.currentState!.save();
                  try {
                    await _persistActivity(
                        act: Activity(title: title, color: selected),
                        onDay: day);
                  } catch (e) {
                    debugPrint('Eroare la salvare: $e');
                  } finally {
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Salvează')),
          ],
        ),
      ),
    );
  }

  void _openUpcomingModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: UpcomingActivitiesModal(
            activities: _activities,
            scrollController: ScrollController(),
          ),
        ),
      ),
    );
  }

  void _push(Widget p) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => p));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(cs),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(cs),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildQuickRow(cs),
                        const SizedBox(height: 24),
                        _buildCalendarAndChart(),
                        const SizedBox(height: 24),
                        _buildBottomRow(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  static const _accent = Colors.deepPurpleAccent;

  Widget _buildSidebar(ColorScheme cs) => Container(
        width: 220,
        color: cs.surface,
        child: Column(
          children: [
            Container(
              height: 100,
              color: cs.primary,
              alignment: Alignment.center,
              child: const Text(
                'Smart Dashboard',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            SidebarButton(
                icon: Icons.dashboard,
                label: 'Dashboard',
                isSelected: true,
                onTap: () {}, accentColor: _accent,),
            SidebarButton(
                icon: Icons.history_edu,
                label: 'Istoric documente',
                onTap: () => _push(const DocumentHistoryScreen()), accentColor: _accent,),
            SidebarButton(
                icon: Icons.history,
                label: 'Istoric test',
                onTap: () => _push(const QuizHistoryScreen()), accentColor: _accent,),
            SidebarButton(
                icon: Icons.notifications_active,
                label: 'Notificări',
                onTap: _openUpcomingModal, accentColor: _accent,),
            const Spacer(),
            SidebarButton(icon: Icons.logout, label: 'Logout', onTap: () {}, accentColor: _accent,),
            const SizedBox(height: 16),
          ],
        ),
      );

  Widget _buildTopBar(ColorScheme cs) => Container(
        height: 70,
        color: cs.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Welcome to Smart',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: cs.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // CircleAvatar(
                //   radius: 20,
                //   backgroundColor: cs.primary,
                //   child: const Icon(Icons.person_rounded, color: Colors.white),
                // ),
                 GestureDetector(
                  onTap: () => _push(const ProfileScreen()),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: cs.primary,
                    child: const Icon(Icons.person_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  /// Aici am schimbat doar culorile, pentru un look mai viu:
  Widget _buildQuickRow(ColorScheme cs) => Row(
        children: [
          Expanded(
            child: _ActionCard(
              color: Colors.blueAccent,
              icon: Icons.upload_file_rounded,
              label: 'Încarcă document',
              onTap: () => _push(const IncarcaDocumentScreen()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionCard(
              color: Colors.pinkAccent,
              icon: Icons.quiz_outlined,
              label: 'Generează test',
              onTap: () => _push(const GenereazaTesteScreen()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionCard(
              color: Colors.orangeAccent,
              icon: Icons.chat_bubble_outline,
              label: 'Conversează document',
              onTap: () => _push(const ChatWithPdfScreen()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ActionCard(
              color: Colors.greenAccent,
              icon: Icons.text_snippet,
              label: 'Quiz din text',
              onTap: () => _push(const GenereazaQuizTextScreen()),
            ),
          ),
        ],
      );

  Widget _buildCalendarAndChart() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: _whiteCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Calendar & Attendance',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: TableCalendar<Activity>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                      calendarFormat: CalendarFormat.month,
                      rowHeight: 30,
                      headerStyle: const HeaderStyle(
                        titleTextStyle: TextStyle(fontSize: 14),
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(Icons.chevron_left, size: 16),
                        rightChevronIcon: Icon(Icons.chevron_right, size: 16),
                      ),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                            color: Colors.deepPurple, shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(
                            color: Colors.purpleAccent, shape: BoxShape.circle),
                      ),
                      eventLoader: _forDay,
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (_, date, ev) =>
                            ev.isEmpty ? const SizedBox() : _buildMarkers(ev),
                      ),
                      onDaySelected: (d, f) {
                        setState(() {
                          _selectedDay = d;
                          _focusedDay = f;
                        });
                        _dialogAddActivity(d);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Activities Notification'),
                      TextButton(
                          onPressed: _openUpcomingModal,
                          child: const Text('View all')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedDay != null && _forDay(_selectedDay!).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activități pentru ${_selectedDay!.toLocal().toString().split(' ')[0]}:',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._forDay(_selectedDay!).map((a) => ListTile(
                              leading:
                                  Icon(Icons.circle, size: 12, color: a.color),
                              title: Text(a.title),
                            )),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: _whiteCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Activity Chart',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                      height: 300,
                      child: TimeSpentChart(timeSpent: _accumulatedTime)),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildMarkers(List<Activity> ev) => Positioned(
        bottom: 1,
        child: Row(
          children: ev
              .map((a) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Tooltip(
                      message: a.title,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, color: a.color),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );

  Widget _buildBottomRow() => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: _whiteCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Top Scorer',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: const [
                        _TopScorerTile(
                            name: 'Brandon Harris',
                            score: '98.7%',
                            color: Colors.deepPurple),
                        _TopScorerTile(
                            name: 'Charlie Sims',
                            score: '96.4%',
                            color: Colors.pink),
                        _TopScorerTile(
                            name: 'Mila Rose',
                            score: '95.2%',
                            color: Colors.orange),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: _whiteCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('School Fee Structure',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      color: Colors.grey[100],
                      child:
                          const Center(child: Text('Fee Structure / Chart')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  BoxDecoration get _whiteCard => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      );
}

class _ActionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.color,
      required this.icon,
      required this.label,
      required this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      );
}

class _TopScorerTile extends StatelessWidget {
  final String name;
  final String score;
  final Color color;
  const _TopScorerTile(
      {required this.name, required this.score, required this.color});

  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(
            backgroundColor: color,
            child: const Icon(Icons.person_rounded, color: Colors.white)),
        title: Text(name),
        subtitle: Text(score),
      );
}