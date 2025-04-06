import 'package:app/src/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/upcoming_activities_modal.dart';
import '../widgets/sidebar_button.dart';
import '../widgets/time_spent_chart.dart';
import '../widgets/incarca_document_screen.dart';
import '../screens/chat_pdf_screen.dart';
import '../screens/genereaza_test_screen.dart';
import '../screens/document_history_screen.dart';

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

  // Pentru monitorizarea timpului petrecut
  Stopwatch _stopwatch = Stopwatch();
  Duration _accumulatedTime = Duration.zero;

  List<Activity> _getActivitiesForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _activities[normalized] ?? [];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _stopwatch.start();
    _fetchActivitiesFromBackend();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopwatch.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Când aplicația intră în fundal, oprim cronometru și acumulăm timpul
    if (state == AppLifecycleState.paused) {
      _stopwatch.stop();
      _accumulatedTime += _stopwatch.elapsed;
    } else if (state == AppLifecycleState.resumed) {
      _stopwatch.reset();
      _stopwatch.start();
    }
  }

  Future<void> _fetchActivitiesFromBackend() async {
    try {
      final list = await _api.fetchActivities();
      final Map<DateTime, List<Activity>> updatedMap = {};

      for (final item in list) {
        final parsedDate = DateTime.parse(item['date']);
        final normalized = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
        updatedMap.putIfAbsent(normalized, () => []).add(
          Activity(
            title: item['title'],
            color: Color(item['color']),
          ),
        );
      }
      setState(() {
        _activities.clear();
        _activities.addAll(updatedMap);
      });
    } catch (e) {
      print("Eroare la preluarea activităților: $e");
    }
  }

  void _showAddActivityDialog(DateTime selectedDay) {
    final _formKey = GlobalKey<FormState>();
    String activityTitle = "";
    Color selectedColor = Colors.blue;
    final List<Color> colorOptions = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Planifică activitate"),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Data: ${selectedDay.toLocal().toString().split(' ')[0]}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Titlu activitate",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Completează titlul";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        activityTitle = value!;
                      },
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      children: colorOptions.map((color) {
                        return ChoiceChip(
                          label: const Text(""),
                          selected: selectedColor == color,
                          selectedColor: color.withOpacity(0.8),
                          backgroundColor: color.withOpacity(0.4),
                          onSelected: (selected) {
                            setStateDialog(() {
                              selectedColor = color;
                            });
                          },
                          avatar: Icon(Icons.circle, color: color, size: 20),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Anulează"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text("Salvează"),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final normalized = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                      );
                      final dateString =
                          '${normalized.year.toString().padLeft(4, '0')}-'
                          '${normalized.month.toString().padLeft(2, '0')}-'
                          '${normalized.day.toString().padLeft(2, '0')}';

                      try {
                        await _api.createActivity(
                          date: dateString,
                          title: activityTitle,
                          colorValue: selectedColor.value,
                        );

                        setState(() {
                          _activities.putIfAbsent(normalized, () => []).add(
                            Activity(title: activityTitle, color: selectedColor),
                          );
                        });
                        Navigator.of(context).pop();
                      } catch (err) {
                        print("Eroare la salvarea activității: $err");
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAllUpcomingActivities() {
    final ScrollController scrollController = ScrollController();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600,
              maxHeight: 500,
            ),
            child: UpcomingActivitiesModal(
              activities: _activities,
              scrollController: scrollController,
            ),
          ),
        );
      },
    );
  }

  void _goToIncarcaDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const IncarcaDocumentScreen()),
    );
  }

  void _goToGenereazaTeste() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GenereazaTesteScreen()),
    );
  }

  void _goToDocumentConversation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatWithPdfScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar-ul din stânga
          Container(
            width: 220,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: 100,
                  color: Colors.deepPurple,
                  alignment: Alignment.center,
                  child: const Text(
                    "Smart Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SidebarButton(
                  icon: Icons.dashboard,
                  label: "Dashboard",
                  isSelected: true,
                  onTap: () {},
                ),
                SidebarButton(
                  icon: Icons.history_edu,
                  label: "Istoric documente",
                  onTap: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DocumentHistoryScreen()),
                  );
                },

                ),
                SidebarButton(
                  icon: Icons.history,
                  label: "Istoric test",
                  onTap: () {},
                ),
                SidebarButton(
                  icon: Icons.notifications_active,
                  label: "Notificări",
                  onTap: () {},
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SidebarButton(
                    icon: Icons.logout,
                    label: "Logout",
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          // Zona principală
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Welcome to Smart",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search...",
                                prefixIcon: const Icon(Icons.search_rounded),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _goToIncarcaDocument,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.upload_file_rounded, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        "Încarcă document",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: _goToGenereazaTeste,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.quiz_outlined, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        "Generează test",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: _goToDocumentConversation,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.chat_bubble_outline, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        "Conversează document",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Calendar & Attendance",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 300,
                                      child: TableCalendar<Activity>(
                                        firstDay: DateTime.utc(2020, 1, 1),
                                        lastDay: DateTime.utc(2030, 12, 31),
                                        focusedDay: _focusedDay,
                                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                        calendarFormat: CalendarFormat.month,
                                        rowHeight: 30,
                                        headerStyle: const HeaderStyle(
                                          titleTextStyle: TextStyle(fontSize: 14),
                                          formatButtonVisible: false,
                                          leftChevronIcon: Icon(Icons.chevron_left, size: 16),
                                          rightChevronIcon: Icon(Icons.chevron_right, size: 16),
                                        ),
                                        calendarBuilders: CalendarBuilders(
                                          markerBuilder: (context, day, events) {
                                            if (events.isEmpty) {
                                              return const SizedBox();
                                            }
                                            return Positioned(
                                              bottom: 1,
                                              child: Row(
                                                children: events.map((activity) {
                                                  return Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 1),
                                                    child: Tooltip(
                                                      message: activity.title,
                                                      child: Container(
                                                        width: 7,
                                                        height: 7,
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: activity.color,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            );
                                          },
                                        ),
                                        calendarStyle: const CalendarStyle(
                                          markerSize: 7,
                                          markersAlignment: Alignment.bottomCenter,
                                          todayDecoration: BoxDecoration(
                                            color: Colors.deepPurple,
                                            shape: BoxShape.circle,
                                          ),
                                          selectedDecoration: BoxDecoration(
                                            color: Colors.purpleAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        onDaySelected: (selectedDay, focusedDay) {
                                          setState(() {
                                            _selectedDay = selectedDay;
                                            _focusedDay = focusedDay;
                                          });
                                          _showAddActivityDialog(selectedDay);
                                        },
                                        onFormatChanged: (format) {},
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Activities Notification"),
                                        TextButton(
                                          onPressed: _showAllUpcomingActivities,
                                          child: const Text("View all"),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (_selectedDay != null &&
                                        _getActivitiesForDay(_selectedDay!).isNotEmpty)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Activități pentru ${_selectedDay!.toLocal().toString().split(' ')[0]}:",
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          ..._getActivitiesForDay(_selectedDay!).map((activity) {
                                            return ListTile(
                                              leading: Icon(Icons.circle, color: activity.color, size: 12),
                                              title: Text(activity.title),
                                            );
                                          }).toList(),
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
                                height: 420,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Activity Chart",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Folosește:
                                    SizedBox(
                                      height: 300, // sau orice înălțime fixă pe care o dorești
                                      child: TimeSpentChart(timeSpent: _accumulatedTime),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 200,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Top Scorer",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: ListView(
                                        children: const [
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.deepPurple,
                                              child: Icon(Icons.person_rounded, color: Colors.white),
                                            ),
                                            title: Text("Brandon Harris"),
                                            subtitle: Text("98.7%"),
                                          ),
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.pink,
                                              child: Icon(Icons.person_rounded, color: Colors.white),
                                            ),
                                            title: Text("Charlie Sims"),
                                            subtitle: Text("96.4%"),
                                          ),
                                          ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.orange,
                                              child: Icon(Icons.person_rounded, color: Colors.white),
                                            ),
                                            title: Text("Mila Rose"),
                                            subtitle: Text("95.2%"),
                                          ),
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
                                height: 200,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "School Fee Structure",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: Container(
                                        color: Colors.grey[100],
                                        child: const Center(
                                          child: Text("Fee Structure / Chart"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
}
