import 'dart:convert';
import 'package:app/src/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  /// Token-ul JWT obținut la login (poate fi gol dacă nu ești autentificat).
  String get _authToken => AuthService.token ?? '';

  /// Creează o nouă activitate (POST /activities → 201 on success).
  Future<void> createActivity({
    required String date,    // "YYYY-MM-DD"
    required String title,
    required int colorValue, // Color.value
  }) async {
    final url = Uri.parse('$baseUrl/activities');
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
    final url = Uri.parse('$baseUrl/activities');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> items = data['activities'] as List<dynamic>;
      return items
          .map((e) => e as Map<String, dynamic>)
          .toList(growable: false);
    } else {
      throw Exception('Eroare la încărcarea activităților: ${response.body}');
    }
  }

  /// Generează un quiz pe baza unui text (POST /generate_quiz_text → 200).
  ///
  /// Returnează direct `http.Response` ca să poți decoda
  /// `response.body` în ecranul tău.
  Future<http.Response> generateQuizFromText({
    required String token,        // JWT
    required String text,         // textul sursă
    required int numQuestions,    // câte întrebări
  }) {
    final url = Uri.parse('$baseUrl/generate_quiz_text');
    return http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'text': text,
        'num_questions': numQuestions,
      }),
    );
  }
}
