import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Pentru Android emulator folosește 10.0.2.2; pentru web/desktop, folosește 'http://127.0.0.1:5000'
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Câmp pentru a stoca tokenul după login
  static String? _token;

  // Getter pentru token
  static String? get token => _token;

  // Metoda de înregistrare
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

  // Metoda de login: returnează token-ul JWT dacă autentificarea e reușită
  static Future<String?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token']; // Stochează tokenul în câmpul static
      return _token;
    } else {
      return null;
    }
  }

  // Exemplu de accesare a unei rute protejate
  static Future<String?> getProtectedData(String token) async {
    final url = Uri.parse('$baseUrl/protected');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message'];
    } else {
      return null;
    }
  }
}
