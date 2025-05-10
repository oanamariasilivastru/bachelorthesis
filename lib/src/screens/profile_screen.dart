// lib/src/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/src/providers/profile_provider.dart';
import 'package:app/src/models/achievement.dart';
import 'package:app/src/models/mission.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // Paletă de culori vii
  static const List<Color> _vibrant = [
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
  ];

  Widget _statCard(
      String label, String value, IconData icon, int index) {
    final color = _vibrant[index % _vibrant.length];
    return Expanded(
      child: Card(
        color: color,
        elevation: 4,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
                  style: const TextStyle(
                      fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  /// Creează un card de misiune cu bară de progres și procent
  Widget _buildMissionCard(Mission m, int index, VoidCallback onTap) {
    final color = _vibrant[index % _vibrant.length];
    // Exemplu de progres; în realitate ai un câmp double progress în Mission
    final progress = m.isCompleted ? 1.0 : 0.4;

    return GestureDetector(
      onTap: m.isCompleted ? null : onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              m.isCompleted ? Icons.check_circle : Icons.timelapse,
              size: 32,
              color: color,
            ),
            Text(
              m.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ],
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

    // Lista extinsă de misiuni (includem și câteva demo suplimentare)
    final allMissions = [
      ...profile.missions,
      Mission(id: 'm_extra1', description: 'Completează 5 quiz-uri', isCompleted: false),
      Mission(id: 'm_extra2', description: 'Încarcă un document PDF', isCompleted: true),
      Mission(id: 'm_extra3', description: 'Planifică o lecție nouă', isCompleted: false),
      Mission(id: 'm_extra4', description: 'Revizuiește notițele de curs', isCompleted: false),
      Mission(id: 'm_extra5', description: 'Răspunde la 10 întrebări', isCompleted: true),
      Mission(id: 'm_extra6', description: 'Menține streak-ul 7 zile', isCompleted: false),
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
                        backgroundColor:
                            _vibrant[0].withOpacity(0.2),
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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(profile.name,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(profile.email,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () =>
                            Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── Stat cards vii ─────────────────
              Row(
                children: [
                  _statCard(
                      'Streak zile',
                      '${profile.currentStreak}',
                      Icons.local_fire_department,
                      0),
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

              // ─── Achievements ────────────────────
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
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
                          final color = _vibrant[
                              idx % _vibrant.length];
                          return Column(
                            mainAxisSize:
                                MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: a.isUnlocked
                                    ? null
                                    : () => prov.unlockAchievement(a.id),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: a.isUnlocked
                                      ? color
                                      : color
                                          .withOpacity(0.3),
                                  child: const Icon(
                                      Icons.emoji_events,
                                      color: Colors.white,
                                      size: 28),
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
                                          : Colors.grey,
                                    )),
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

              // ─── Provocări (orizontal) ───────────
              const Text('Provocări',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allMissions.length,
                  itemBuilder: (ctx, i) => _buildMissionCard(
                      allMissions[i], i, () {
                    // marchează completarea
                    prov.completeMission(allMissions[i].id);
                  }),
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
