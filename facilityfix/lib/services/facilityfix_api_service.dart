import 'dart:convert';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import '../models/api_models.dart';

class FacilityFixAPIService {
  final http.Client _client;
  late String baseUrl;
  String? _authToken;

  FacilityFixAPIService({http.Client? client, String? lanIp})
    : _client = client ?? http.Client() {
    if (kIsWeb) {
      // Web app running on the same PC as backend
      baseUrl = 'http://localhost:8000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Android:
      // - emulator: 10.0.2.2
      // - real device on Wi-Fi: pass your PC's LAN IP (could be change based sa mag oopen ng backend nad front at the same time)
      baseUrl =
          (lanIp != null && lanIp.isNotEmpty)
              ? 'http://192.168.18.10:8000' // provided LAN IP
              : 'http://10.0.2.2:8000'; // emulator default
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS simulator shares host network
      baseUrl = 'http://localhost:8000';
    } else {
      // Desktop/other
      baseUrl = 'http://localhost:8000';
    }

    // ignore: avoid_print
    print(
      '[FacilityFix] APIService initialized with baseUrl: $baseUrl (kIsWeb=$kIsWeb, platform=$defaultTargetPlatform)',
    );
  }

  // Auth token management
  void setAuthToken(String token) {
    _authToken = token;
    // ignore: avoid_print
    print('[FacilityFix] Auth token set');
  }

  void clearAuthToken() {
    _authToken = null;
    // ignore: avoid_print
    print('[FacilityFix] Auth token cleared');
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Connectivity
  Future<bool> testConnection() async {
    try {
      final uri = Uri.parse('$baseUrl/health'); // prefer /health
      // ignore: avoid_print
      print('[FacilityFix] Testing connection: $uri');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 5));
      // ignore: avoid_print
      print(
        '[FacilityFix] /health status: ${response.statusCode} body: ${response.body}',
      );
      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Connection test failed: $e');
      return false;
    }
  }

  // AUTH
  Future<AuthResponse> exchangeToken(String firebaseToken) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/exchange-token'),
        headers: _headers,
        body: jsonEncode({'firebase_token': firebaseToken}),
      );
      // ignore: avoid_print
      print('[FacilityFix] Exchange token response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(
          data,
        ); // expects accessToken, tokenType
        setAuthToken(authResponse.accessToken);
        return authResponse;
      }
      throw Exception(
        'Failed to exchange token: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error during token exchange: $e');
      rethrow;
    }
  }

  Future<UserResponse> registerUser(UserRegistrationRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );
      // ignore: avoid_print
      print('[FacilityFix] Register user response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserResponse.fromJson(data);
      }
      throw Exception(
        'Failed to register user: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error during user registration: $e');
      rethrow;
    }
  }

  // REPAIR REQUESTS
  Future<RepairRequestResponse> submitRepairRequest(
    RepairRequestSubmission request,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/repair-requests/'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );
      // ignore: avoid_print
      print(
        '[FacilityFix] Submit repair request response: ${response.statusCode}',
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RepairRequestResponse.fromJson(data);
      }
      throw Exception(
        'Failed to submit repair request: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error submitting repair request: $e');
      rethrow;
    }
  }

  Future<List<RepairRequestResponse>> getUserRepairRequests(
    String userId,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/repair-requests/$userId'),
        headers: _headers,
      );
      // ignore: avoid_print
      print(
        '[FacilityFix] Get user repair requests response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => RepairRequestResponse.fromJson(e)).toList();
      }
      throw Exception(
        'Failed to get repair requests: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error getting repair requests: $e');
      rethrow;
    }
  }

  Future<List<RepairRequestResponse>> getAllRepairRequests() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/repair-requests/'),
        headers: _headers,
      );
      // ignore: avoid_print
      print(
        '[FacilityFix] Get all repair requests response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => RepairRequestResponse.fromJson(e)).toList();
      }
      throw Exception(
        'Failed to get all repair requests: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error getting all repair requests: $e');
      rethrow;
    }
  }

  Future<RepairRequestResponse> updateRepairRequestStatus(
    String requestId,
    String status, {
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'status': status,
        if (notes != null) 'notes': notes,
      };
      final response = await _client.patch(
        Uri.parse('$baseUrl/repair-requests/$requestId/status'),
        headers: _headers,
        body: jsonEncode(body),
      );
      // ignore: avoid_print
      print(
        '[FacilityFix] Update repair request status response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RepairRequestResponse.fromJson(data);
      }
      throw Exception(
        'Failed to update repair request status: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error updating repair request status: $e');
      rethrow;
    }
  }

  // WORK ORDERS
  Future<WorkOrderResponse> createWorkOrder(WorkOrderCreation request) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/work-orders/'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );
      // ignore: avoid_print
      print('[FacilityFix] Create work order response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WorkOrderResponse.fromJson(data);
      }
      throw Exception(
        'Failed to create work order: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error creating work order: $e');
      rethrow;
    }
  }

  Future<List<WorkOrderResponse>> getAssignedWorkOrders(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/work-orders/assigned/$userId'),
        headers: _headers,
      );
      // ignore: avoid_print
      print(
        '[FacilityFix] Get assigned work orders response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => WorkOrderResponse.fromJson(e)).toList();
      }
      throw Exception(
        'Failed to get assigned work orders: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error getting assigned work orders: $e');
      rethrow;
    }
  }

  Future<WorkOrderResponse> updateWorkOrderStatus(
    String workOrderId,
    String status, {
    String? notes,
  }) async {
    try {
      final body = <String, dynamic>{
        'status': status,
        if (notes != null) 'notes': notes,
      };
      final response = await _client.patch(
        Uri.parse('$baseUrl/api/work-orders/$workOrderId/status'),
        headers: _headers,
        body: jsonEncode(body),
      );
      // ignore: avoid_print
      print(
        '[FacilityFix] Update work order status response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return WorkOrderResponse.fromJson(data);
      }
      throw Exception(
        'Failed to update work order status: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error updating work order status: $e');
      rethrow;
    }
  }

  //  USERS
  Future<List<UserResponse>> getAllUsers() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/users/'),
        headers: _headers,
      );
      // ignore: avoid_print
      print('[FacilityFix] Get all users response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => UserResponse.fromJson(e)).toList();
      }
      throw Exception(
        'Failed to get users: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error getting users: $e');
      rethrow;
    }
  }

  Future<UserResponse> getUser(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
      );
      // ignore: avoid_print
      print('[FacilityFix] Get user response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserResponse.fromJson(data);
      }
      throw Exception(
        'Failed to get user: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error getting user: $e');
      rethrow;
    }
  }

  Future<UserResponse> updateUser(
    String userId,
    UserUpdateRequest request,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );
      // ignore: avoid_print
      print('[FacilityFix] Update user response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserResponse.fromJson(data);
      }
      throw Exception(
        'Failed to update user: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error updating user: $e');
      rethrow;
    }
  }

  //  DB Utils
  Future<bool> testDatabaseConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/database/test'),
        headers: _headers,
      );
      // ignore: avoid_print
      print(
        '[FacilityFix] Test database connection response: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Database connection test failed: $e');
      return false;
    }
  }

  Future<bool> initializeSampleData() async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/database/init-sample-data'),
        headers: _headers,
      );
      // ignore: avoid_print
      print(
        '[FacilityFix] Initialize sample data response: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } catch (e) {
      // ignore: avoid_print
      print('[FacilityFix] Error initializing sample data: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getCurrentUserProfile(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        '[FacilityFix] Get current user profile response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      }
      throw Exception(
        'Failed to get user profile: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      print('[FacilityFix] Error getting user profile: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllConcernSlips() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/concern-slips/'),
        headers: _headers,
      );

      print(
        '[FacilityFix] Get all concern slips response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      }
      throw Exception(
        'Failed to get concern slips: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      print('[FacilityFix] Error getting concern slips: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }

  // ===== Announcements API =====

  Future<Map<String, dynamic>> createAnnouncement(
    CreateAnnouncementRequest request,
    String idToken,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/announcements/'),
        headers: {..._headers, 'Authorization': 'Bearer $idToken'},
        body: jsonEncode(request.toJson()),
      );
      // 200 or 201 are both fine depending on backend return
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(
        'Create announcement failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AnnouncementListResponse> getAnnouncements({
    required String buildingId,
    String audience = 'all',
    bool activeOnly = true,
    int limit = 50,
    bool includeDismissed = false,
    required String idToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/announcements/').replace(
        queryParameters: {
          'building_id': buildingId,
          'audience': audience,
          'active_only': activeOnly.toString(),
          'limit': limit.toString(),
          'include_dismissed': includeDismissed.toString(),
        },
      );
      final response = await _client.get(
        uri,
        headers: {..._headers, 'Authorization': 'Bearer $idToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AnnouncementListResponse.fromJson(data);
      }
      throw Exception(
        'Get announcements failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AnnouncementResponse> getAnnouncementById(
    String announcementId,
    String idToken,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/announcements/$announcementId'),
        headers: {..._headers, 'Authorization': 'Bearer $idToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AnnouncementResponse.fromJson(data);
      }
      throw Exception(
        'Get announcement failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateAnnouncement(
    String announcementId,
    UpdateAnnouncementRequest updates,
    String idToken,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/announcements/$announcementId'),
        headers: {..._headers, 'Authorization': 'Bearer $idToken'},
        body: jsonEncode(updates.toJson()),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(
        'Update announcement failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deactivateAnnouncement(
    String announcementId, {
    bool notifyDeactivation = false,
    required String idToken,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/announcements/$announcementId').replace(
        queryParameters: {'notify_deactivation': notifyDeactivation.toString()},
      );
      final response = await _client.delete(
        uri,
        headers: {..._headers, 'Authorization': 'Bearer $idToken'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(
        'Deactivate announcement failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rebroadcastAnnouncement(
    String announcementId,
    String idToken,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/announcements/$announcementId/rebroadcast'),
        headers: {..._headers, 'Authorization': 'Bearer $idToken'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(
        'Rebroadcast failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> dismissAnnouncement(
    String announcementId,
    String idToken,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/announcements/$announcementId/dismiss'),
        headers: {..._headers, 'Authorization': 'Bearer $idToken'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(
        'Dismiss failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAvailableAnnouncementTypes(
    String idToken,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/announcements/types/available'),
        headers: {..._headers, 'Authorization': 'Bearer $idToken'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception(
        'Get types failed: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      rethrow;
    }
  }
}
