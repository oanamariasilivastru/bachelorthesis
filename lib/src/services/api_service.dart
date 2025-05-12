// lib/src/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:app/src/services/auth_service.dart';
import 'package:app/src/models/user_profile.dart';
import 'package:app/src/models/quiz_history_item.dart';

/// Wrapper peste toate apelurile HTTP către backend-ul Flask.
/// Toate metodele aruncă [Exception] cu mesaj detaliat când codul de răspuns
/// nu este cel așteptat, pentru a fi prins de UI (FutureBuilder / bloc etc.).
class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:5000';

  /// Token-ul JWT obţinut la login (poate fi gol dacă nu ești autentificat).
  String get _authToken => AuthService.token ?? '';

  /* ------------------------------------------------------------------------ */
  /*  ACTIVITĂŢI                                                             */
  /* ------------------------------------------------------------------------ */

  /// Creează o nouă activitate (POST /activities → 201 on success).
  Future<void> createActivity({
    required String date,
    required String title,
    required int colorValue,
  }) async {
    final url = Uri.parse('$_baseUrl/activities');
    final response = await http.post(
      url,
      headers: _defaultHeaders,
      body: jsonEncode({
        'date': date,
        'title': title,
        'color': colorValue,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Eroare la crearea activităţii: ${response.body}');
    }
  }

  /// Preia toate activităţile (GET /activities → 200).
  Future<List<Map<String, dynamic>>> fetchActivities() async {
    final url = Uri.parse('$_baseUrl/activities');
    final response = await http.get(url, headers: _defaultHeaders);

    if (response.statusCode != 200) {
      throw Exception('Eroare la încărcarea activităţilor: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['activities'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  /* ------------------------------------------------------------------------ */
  /*  QUIZ                                                                   */
  /* ------------------------------------------------------------------------ */

  /// Generează un quiz pe baza unui text.
  /// [language] trebuie să fie 'ro' sau 'en'.
  Future<http.Response> generateQuizFromText({
    required String text,
    required int numQuestions,
    required String language,
  }) async {
    final path = language.toLowerCase() == 'en' ? '/generate_mcq_en' : '/generate_mcq';
    final url = Uri.parse('$_baseUrl$path');

    final response = await http.post(
      url,
      headers: _defaultHeaders,
      body: jsonEncode({
        'text': text,
        'num_questions': numQuestions,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Eroare la generarea quiz‑ului (${response.statusCode}): ${response.body}');
    }
    return response;
  }

  /// Preia istoricul de quiz‑uri ca [http.Response] brut.
  /// Poate fi util pentru debug sau dacă vrei să procesezi manual datele.
  Future<http.Response> fetchQuizHistoryRaw() async {
    final url = Uri.parse('$_baseUrl/test_records');
    final response = await http.get(url, headers: _defaultHeaders);

    if (response.statusCode != 200) {
      throw Exception('Eroare la încărcarea istoricului quiz‑urilor: ${response.body}');
    }
    return response;
  }

  /// Preia istoricul de quiz‑uri şi îl converteşte în modele [QuizHistoryItem].
  Future<List<QuizHistoryItem>> fetchQuizHistory() async {
    final res = await fetchQuizHistoryRaw();

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = data['quiz_history'] as List<dynamic>? ?? [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(QuizHistoryItem.fromJson)
        .toList();
  }

  /* ------------------------------------------------------------------------ */
  /*  PROFIL & GAMIFICARE                                                    */
  /* ------------------------------------------------------------------------ */

  /// Preia profilul utilizatorului.
  Future<UserProfile> fetchUserProfile() async {
    final url = Uri.parse('$_baseUrl/profile');
    final response = await http.get(url, headers: _defaultHeaders);

    if (response.statusCode != 200) {
      throw Exception('Eroare la încărcarea profilului: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  /// Deblochează un achievement.
  Future<void> unlockAchievement(String achievementId) async {
    final url = Uri.parse('$_baseUrl/achievements/$achievementId/unlock');
    final response = await http.post(url, headers: _defaultHeaders);

    if (response.statusCode != 200) {
      throw Exception('Eroare la deblocarea realizării ($achievementId): ${response.body}');
    }
  }

  /// Marchează o misiune ca finalizată.
  Future<void> completeMission(String missionId) async {
    final url = Uri.parse('$_baseUrl/missions/$missionId/complete');
    final response = await http.post(url, headers: _defaultHeaders);

    if (response.statusCode != 200) {
      throw Exception('Eroare la finalizarea misiunii ($missionId): ${response.body}');
    }
  }

  /* ------------------------------------------------------------------------ */
  /*  HELPERS                                                                */
  /* ------------------------------------------------------------------------ */

  /// Header-ele comune tuturor request‑urilor.
  Map<String, String> get _defaultHeaders => {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      }..removeWhere((_, v) => v.isEmpty);
}
