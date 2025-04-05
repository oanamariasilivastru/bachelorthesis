/// Clasa care se ocupă cu request-uri către backend.
/// Păstreaz-o într-un fișier separat sau imediat sub HomeScreen.
/// Aici e un exemplu minimal pentru /activities:
import 'dart:convert';
import 'package:app/src/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';  // schimbă la nevoie

  final String authToken = AuthService.token ?? ""; // token JWT obținut la login

  // POST /activities
  // Trimite datele unei noi activități la backend
  Future<void> createActivity({
    required String date,       // "YYYY-MM-DD"
    required String title,
    required int colorValue,    // reprezentarea numerică a culorii (Color.value)
  }) async {
    final url = Uri.parse('$baseUrl/activities');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
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

  // GET /activities
  // Ia toate activitățile de la backend (dacă vrei să le refaci după un refresh)
  Future<List<Map<String, dynamic>>> fetchActivities() async {
    final url = Uri.parse('$baseUrl/activities');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> activities = data['activities'];
      return activities.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Eroare la încărcarea activităților: ${response.body}');
    }
  }
}
