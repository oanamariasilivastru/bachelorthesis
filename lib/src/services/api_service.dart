// lib/src/services/api_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'auth_service.dart';
import '../models/user_profile.dart';
import '../models/quiz_history_item.dart';

class ApiService {
  /*--------------- singleton ---------------*/
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  /*--------------- config ---------------*/
  final String _baseUrl = AuthService.baseUrl;

  String get _jwt => AuthService.token ?? '';

  /* Headers JSON (folosite la toate request-urile JSON) */
  Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        if (_jwt.isNotEmpty) 'Authorization': 'Bearer $_jwt',
      };

  /* Headers doar cu auth (pentru Multipart etc.) */
  Map<String, String> get _authHeaders =>
      _jwt.isEmpty ? {} : {'Authorization': 'Bearer $_jwt'};


  Future<void> createActivity({
    required String date,
    required String title,
    required int colorValue,
  }) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/activities'),
      headers: _jsonHeaders,
      body: jsonEncode({'date': date, 'title': title, 'color': colorValue}),
    );

    if (res.statusCode != 201) {
      throw Exception('createActivity → ${res.statusCode}: ${res.body}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchActivities() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/activities'),
      headers: _jsonHeaders,
    );

    if (res.statusCode != 200) {
      throw Exception('fetchActivities → ${res.statusCode}: ${res.body}');
    }
    return (jsonDecode(res.body)['activities'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
  }

  Future<http.Response> generateQuizFromText({
    required String text,
    required int numQuestions,
    required String language, // 'ro' | 'en'
  }) async {
    final path =
        language.toLowerCase() == 'ro' ? '/generate_mcq_ro' : '/generate_mcq_en';

    final res = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: _jsonHeaders,
      body: jsonEncode({'text': text, 'num_questions': numQuestions}),
    );

    if (res.statusCode != 200) {
      throw Exception(
          'generateQuizFromText → ${res.statusCode}: ${res.body}');
    }
    return res;
  }

  Future<http.Response> generateQuizFromPdf({
    required File pdf,
    required int numQuestions,
    required String language, // 'ro' | 'en'
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/generate_test'),
    )
      ..headers.addAll(_authHeaders)
      ..fields['language'] = language
      ..fields['num_questions'] = numQuestions.toString()
      ..files.add(await http.MultipartFile.fromPath(
        'document',
        pdf.path,
        contentType: MediaType('application', 'pdf'),
      ));

    final streamRes =
        await req.send().timeout(const Duration(minutes: 5), onTimeout: () {
      req.finalize();
      throw const SocketException('Upload PDF timeout');
    });

    final res = await http.Response.fromStream(streamRes);

    if (res.statusCode != 200) {
      throw Exception('generateQuizFromPdf → ${res.statusCode}: ${res.body}');
    }
    return res;
  }

  Future<List<QuizHistoryItem>> fetchQuizHistory() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/test_records'),
      headers: _jsonHeaders,
    );

    if (res.statusCode != 200) {
      throw Exception('fetchQuizHistory → ${res.statusCode}: ${res.body}');
    }

    return (jsonDecode(res.body)['quiz_history'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(QuizHistoryItem.fromJson)
        .toList();
  }


  Future<UserProfile> fetchUserProfile() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: _jsonHeaders,
    );
    if (res.statusCode != 200) {
      throw Exception('fetchUserProfile → ${res.statusCode}: ${res.body}');
    }
    return UserProfile.fromJson(jsonDecode(res.body));
  }

  Future<void> unlockAchievement(String id) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/achievements/$id/unlock'),
      headers: _authHeaders,
    );
    if (res.statusCode != 200) {
      throw Exception('unlockAchievement → ${res.statusCode}: ${res.body}');
    }
  }

  Future<void> completeMission(String id) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/missions/$id/complete'),
      headers: _authHeaders,
    );
    if (res.statusCode != 200) {
      throw Exception('completeMission → ${res.statusCode}: ${res.body}');
    }
  }
}
