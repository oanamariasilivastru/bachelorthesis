// lib/src/services/api_service.dart

import 'dart:convert';
import 'package:app/src/services/auth_service.dart';
import 'package:app/src/models/user_profile.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:5000';

  /// Token-ul JWT obținut la login (poate fi gol dacă nu ești autentificat).
  String get _authToken => AuthService.token ?? '';

  /// Creează o nouă activitate (POST /activities → 201 on success).
  Future<void> createActivity({
    required String date,    // "YYYY-MM-DD"
    required String title,
    required int colorValue, // Color.value
  }) async {
    final url = Uri.parse('$_baseUrl/activities');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'date': date,
        'title': title,
        'color': colorValue,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Eroare la crearea activității: ${response.body}');
    }
  }

  /// Preia toate activitățile (GET /activities → 200).
  Future<List<Map<String, dynamic>>> fetchActivities() async {
    final url = Uri.parse('$_baseUrl/activities');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Eroare la încărcarea activităților: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['activities'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  /// Generează un quiz pe baza unui text, în funcție de limbă.
  ///
  /// - Engleză → POST /generate_mcq_en
  /// - Română  → POST /generate_mcq_ro
  Future<http.Response> generateQuizFromText({
    required String text,
    required int numQuestions,
    required String language, // 'ro' | 'en'
  }) async {
    final path = language.toLowerCase() == 'en'
        ? '/generate_mcq_en'
        : '/generate_mcq_ro';
    final url = Uri.parse('$_baseUrl$path');
    final payload = {
      'text': text,
      'num_questions': numQuestions,
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Eroare la generarea quiz-ului (${response.statusCode}): ${response.body}',
      );
    }
    return response;
  }

  /// Preia profilul utilizatorului, inclusiv streak, achievements și missions.
  /// GET /profile → 200 + JSON { user_id, name, email, current_streak, last_active_date, achievements, missions }
  Future<UserProfile> fetchUserProfile() async {
    final url = Uri.parse('$_baseUrl/profile');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Eroare la încărcarea profilului: ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  /// Deblochează un achievement (POST /achievements/{id}/unlock → 200).
  Future<void> unlockAchievement(String achievementId) async {
    final url = Uri.parse('$_baseUrl/achievements/$achievementId/unlock');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Eroare la deblocarea realizării ($achievementId): ${response.body}',
      );
    }
  }

  /// Marchează o misiune ca finalizată (POST /missions/{id}/complete → 200).
  Future<void> completeMission(String missionId) async {
    final url = Uri.parse('$_baseUrl/missions/$missionId/complete');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Eroare la finalizarea misiunii ($missionId): ${response.body}',
      );
    }
  }
}
