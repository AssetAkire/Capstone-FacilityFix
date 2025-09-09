import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:facilityfix/config/env.dart';
import 'package:facilityfix/models/scenario_models.dart';
import 'package:facilityfix/models/reading_model.dart';

class APIService {
  final http.Client _client;
  final AppRole role;
  late final String baseUrl;

  APIService({http.Client? client, AppRole? roleOverride})
      : _client = client ?? http.Client(),
        role = roleOverride ?? AppEnv.role {
    baseUrl = AppEnv.resolveBaseUrl(overrideRole: role);
    // ignore: avoid_print
    print('APIService init → role=$role | baseUrl=$baseUrl | kIsWeb=$kIsWeb');
  }

  Future<Map<String, dynamic>> fetchMessagesAndPath(
      String phone, String firstName, String lastName) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/messages'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // ignore: avoid_print
    print('fetchMessagesAndPath ${res.statusCode} → ${res.body}');
    throw Exception('Failed to fetch messages and path');
  }

  Future<List<Map<String, dynamic>>> fetchSuggestions(String filePath) async {
    final res = await _client.get(
      Uri.parse('$baseUrl/suggestion?file_path=${Uri.encodeComponent(filePath)}'),
    );
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic> && decoded['suggestions'] is List) {
        return (decoded['suggestions'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    }
    // ignore: avoid_print
    print('fetchSuggestions ${res.statusCode} → ${res.body}');
    return [];
  }

  Future<Map<String, dynamic>> analyzeMessages(String filePath) async {
    final uri =
        Uri.parse('$baseUrl/analyze_messages?file_path=${Uri.encodeComponent(filePath)}');
    final res = await _client.get(uri);
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    // ignore: avoid_print
    print('analyzeMessages ${res.statusCode} → ${res.body}');
    throw Exception('Failed to analyze messages: ${res.statusCode}');
  }

  // ---- Scenario APIs ----
  Future<ConfigResponse> startConversation() async {
    final res = await _client.get(
      Uri.parse('$baseUrl/start'),
      headers: const {'Content-Type': 'application/json'},
    );
    if (res.statusCode == 200) {
      return ConfigResponse.fromJson(jsonDecode(res.body));
    }
    // ignore: avoid_print
    print('startConversation ${res.statusCode} → ${res.body}');
    throw Exception('Failed to start conversation');
  }

  Future<ChatResponse> sendMessage(ChatRequest request) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/chat'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 200) {
      return ChatResponse.fromJson(jsonDecode(res.body));
    }
    // ignore: avoid_print
    print('sendMessage ${res.statusCode} → ${res.body}');
    throw Exception('Failed to send message');
  }

  Future<EvaluationResponse> evaluateConversation(EvaluationRequest request) async {
    final res = await _client.post(
      Uri.parse('$baseUrl/evaluate'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (res.statusCode == 200) {
      return EvaluationResponse.fromJson(jsonDecode(res.body));
    }
    // ignore: avoid_print
    print('evaluateConversation ${res.statusCode} → ${res.body}');
    throw Exception('Failed to evaluate conversation');
  }

  // ---- Utilities ----
  Future<bool> testConnection() async {
    try {
      final res = await _client
          .get(
            Uri.parse('$baseUrl/'),
            headers: const {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Reading>> fetchAllReadings() async {
    final res = await _client.get(Uri.parse('$baseUrl/resources/all'));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      if (decoded is List) {
        return decoded
            .map<Reading>((e) => Reading.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (decoded is Map && decoded['data'] is List) {
        final list = decoded['data'] as List;
        return list
            .map<Reading>((e) => Reading.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    throw Exception('Failed to fetch readings: ${res.statusCode} ${res.body}');
  }
}
