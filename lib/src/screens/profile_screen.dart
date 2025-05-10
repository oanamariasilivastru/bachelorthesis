// lib/src/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/src/providers/profile_provider.dart';
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

  /// Creează un card de misiune cu fundal alb și accente colorate
  Widget _buildMissionCard(Mission m, int index, VoidCallback onTap) {
    final color = _vibrant[index % _vibrant.length];
    final progress = m.isCompleted ? 1.0 : 0.4;

    return GestureDetector(
      onTap: m.isCompleted ? null : onTap,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: color, width: 1.5)),
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
              // Header
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
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
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

              // Stat cards
              Row(
                children: [
                  _statCard('Streak zile', '${profile.currentStreak}',
                      Icons.local_fire_department, 0),
                  const SizedBox(width: 8),
                  _statCard(
                      'Crowns',
                      profile.achievements
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
                      profile.achievements
                          .where((a) => a.isUnlocked)
                          .length
                          .toString(),
                      Icons.star,
                      3),
                ],
              ),

              const SizedBox(height: 24),

              // Achievements
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Realizări',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: profile.achievements
                            .asMap()
                            .entries
                            .map((e) {
                          final idx = e.key;
                          final a = e.value;
                          final color = _vibrant[idx % _vibrant.length];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: a.isUnlocked
                                    ? null
                                    : () => prov.unlockAchievement(a.id),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: a.isUnlocked
                                      ? color
                                      : color.withOpacity(0.3),
                                  child: const Icon(Icons.emoji_events,
                                      color: Colors.white, size: 28),
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
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Provocări (vertical, secțiune albă)
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                m, i, () => prov.completeMission(m.id)),
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
