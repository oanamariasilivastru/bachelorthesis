// lib/src/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Pentru Android emulator folosește 10.0.2.2; pentru web/desktop, folosește 'http://127.0.0.1:5000'
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Câmp intern pentru a stoca token-ul după login
  static String? _token;

  // Getter public pentru token
  static String? get token => _token;

  /// Înregistrează un user nou. Returnează true dacă a fost creat cu succes (HTTP 201).
  static Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );
    return response.statusCode == 201;
  }

  /// Face login și, dacă e reușit (HTTP 200), stochează și returnează token-ul JWT.
  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      _token = data['token'] as String?;
      return _token;
    }
    return null;
  }

  /// Șterge token-ul local, adică dă logout.
  static void logout() {
    _token = null;
  }

  /// Exemplu de apel la o rutină protejată
  static Future<Map<String, dynamic>?> getProtectedData() async {
    if (_token == null) return null;
    final url = Uri.parse('$baseUrl/protected');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  /// Apelează endpoint-ul /quiz_history
  static Future<http.Response> fetchQuizHistory() async {
    if (_token == null) throw Exception('Not authenticated');
    final url = Uri.parse('$baseUrl/quiz_history');
    return await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    });
  }

  /// Apelează endpoint-ul /activities
  static Future<List<Map<String, dynamic>>> fetchActivities() async {
    if (_token == null) throw Exception('Not authenticated');
    final url = Uri.parse('$baseUrl/activities');
    final res = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    });
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['activities'] as List);
    } else {
      throw Exception('Failed to load activities');
    }
  }

  /// Creează o nouă activitate
  static Future<void> createActivity({
    required String date,
    required String title,
    required int colorValue,
  }) async {
    if (_token == null) throw Exception('Not authenticated');
    final url = Uri.parse('$baseUrl/activities');
    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode({
        'date': date,
        'title': title,
        'color': colorValue,
      }),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to create activity');
    }
  }
}
