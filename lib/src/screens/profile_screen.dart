// lib/src/screens/profile_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/src/providers/profile_provider.dart';
import 'package:app/src/models/achievement.dart';
import 'package:app/src/models/mission.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // Paletă de culori vii pentru accente
  static const List<Color> _vibrant = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
  ];

  Widget _statCard(String label, String value, IconData icon, int index) {
    final color = _vibrant[index % _vibrant.length];
    return Expanded(
      child: Card(
        color: color,
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  void _showMissionDetails(
      BuildContext context, Mission m, int index, int total) {
    final color = _vibrant[index % _vibrant.length];
    final raw = (index + 1) / total;
    final progress = m.isCompleted ? 1.0 : min(raw, 0.99);
    final prov = Provider.of<ProfileProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(m.description,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).round()}% finalizat',
                style:
                    TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (!m.isCompleted)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () {
                  prov.completeMission(m.id);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check),
                label: const Text('Marchează ca finalizată'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Închide'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(
      BuildContext context, Mission m, int index, int total) {
    final color = _vibrant[index % _vibrant.length];
    final raw = (index + 1) / total;
    final progress = m.isCompleted ? 1.0 : min(raw, 0.99);

    return GestureDetector(
      onTap: () => _showMissionDetails(context, m, index, total),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                m.isCompleted ? Icons.check_circle : Icons.timelapse,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                m.description,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).round()}% finalizat',
                textAlign: TextAlign.right,
                style:
                    TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProfileProvider>();
    if (prov.isLoading || prov.profile == null) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final profile = prov.profile!;

    // Lista demo realizări
    final allAchievements = [
      ...profile.achievements,
      Achievement(
          id: 'a1',
          title: 'Primul quiz',
          description: 'Finalizează primul quiz generat automat',
          isUnlocked: false),
      Achievement(
          id: 'a2',
          title: 'Încărcare PDF',
          description: 'Încarcă un document PDF pentru QA',
          isUnlocked: false),
      Achievement(
          id: 'a3',
          title: 'Streak 3 zile',
          description: 'Folosește aplicația 3 zile consecutive',
          isUnlocked: false),
      Achievement(
          id: 'a4',
          title: '10 răspunsuri',
          description: 'Răspunde corect la 10 întrebări din quiz-uri',
          isUnlocked: false),
      Achievement(
          id: 'a5',
          title: 'Planifică lecție',
          description: 'Adaugă o activitate în calendar',
          isUnlocked: false),
      Achievement(
          id: 'a6',
          title: 'Quiz avansat',
          description: 'Generează și finalizează un quiz cu >5 întrebări',
          isUnlocked: false),
      Achievement(
          id: 'a7',
          title: 'PDF extins',
          description: 'Încarcă un PDF cu >50 de pagini',
          isUnlocked: false),
      Achievement(
          id: 'a8',
          title: '100 XP',
          description: 'Câștigă cel puțin 100 de puncte XP',
          isUnlocked: false),
      Achievement(
          id: 'a9',
          title: 'Calendar expert',
          description: 'Adaugă 10 activități în calendar',
          isUnlocked: false),
      Achievement(
          id: 'a10',
          title: 'Feedback rapid',
          description: 'Obține răspuns instant la o întrebare în <5 secunde',
          isUnlocked: false),
    ];

    // Lista demo misiuni
    final allMissions = [
      ...profile.missions,
      Mission(
          id: 'm1',
          description: 'Generează 3 quiz-uri din text',
          isCompleted: false),
      Mission(
          id: 'm2',
          description: 'Generează un quiz dintr-un PDF încărcat',
          isCompleted: false),
      Mission(
          id: 'm3',
          description: 'Răspunde la 10 întrebări din documente',
          isCompleted: false),
      Mission(
          id: 'm4',
          description: 'Planifică 5 activități în calendar',
          isCompleted: false),
      Mission(
          id: 'm5',
          description: 'Menține streak-ul 3 zile consecutive',
          isCompleted: false),
      Mission(
          id: 'm6',
          description: 'Petrece minim 30 minute în aplicație azi',
          isCompleted: true),
      Mission(
          id: 'm7',
          description: 'Revizuiește notițele încărcate săptămâna aceasta',
          isCompleted: false),
      Mission(
          id: 'm8',
          description: 'Obține peste 80% la un test generat',
          isCompleted: false),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header ─────────────────────────
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: _vibrant[0].withOpacity(0.2),
                        child: Text(
                          profile.name[0],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _vibrant[0],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.name,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(profile.email,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── Stat cards ────────────────────
              Row(
                children: [
                  _statCard('Streak zile', '${profile.currentStreak}',
                      Icons.local_fire_department, 0),
                  const SizedBox(width: 8),
                  _statCard(
                      'Crowns',
                      allAchievements
                          .where((a) => a.isUnlocked)
                          .length
                          .toString(),
                      Icons.emoji_events,
                      1),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _statCard(
                      'Misiuni',
                      allMissions
                          .where((m) => m.isCompleted)
                          .length
                          .toString(),
                      Icons.check_circle,
                      2),
                  const SizedBox(width: 8),
                  _statCard(
                      'Badge-uri',
                      allAchievements
                          .where((a) => a.isUnlocked)
                          .length
                          .toString(),
                      Icons.star,
                      3),
                ],
              ),

              const SizedBox(height: 24),

              // ─── Achievements ───────────────────
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text('Realizări',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: allAchievements
                            .asMap()
                            .entries
                            .map((e) {
                          final idx = e.key;
                          final a = e.value;
                          final color = _vibrant[idx % _vibrant.length];
                          return Tooltip(
                            message: a.description,
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: a.isUnlocked
                                      ? color
                                      : color.withOpacity(0.2),
                                  child: Icon(
                                    Icons.emoji_events,
                                    color: a.isUnlocked
                                        ? Colors.white
                                        : color.withOpacity(0.6),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                SizedBox(
                                  width: 60,
                                  child: Text(a.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: a.isUnlocked
                                              ? Colors.black
                                              : Colors.grey)),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── Provocări ─────────────────────
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      const Text('Provocări',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Column(
                        children: List.generate(allMissions.length, (i) {
                          final m = allMissions[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildMissionCard(
                                context, m, i, allMissions.length),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
