// lib/src/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/src/providers/profile_provider.dart';
import 'package:app/src/models/achievement.dart';
import 'package:app/src/models/mission.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  // Paleta de culori vii
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProfileProvider>();
    final profile = prov.profile;
    if (prov.isLoading || profile == null) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                                    fontWeight: FontWeight.bold)),
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
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Stat cards vii
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
                      profile.missions
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

              // Missions
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text('Provocări',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...profile.missions.map((m) {
                        return Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: 4),
                          child: CheckboxListTile(
                            tileColor: m.isCompleted
                                ? _vibrant[4]
                                    .withOpacity(0.2)
                                : null,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            title: Text(m.description),
                            value: m.isCompleted,
                            activeColor: _vibrant[4],
                            onChanged: m.isCompleted
                                ? null
                                : (_) => prov.completeMission(m.id),
                          ),
                        );
                      }).toList(),
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
