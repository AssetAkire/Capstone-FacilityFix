import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/env.dart';

class ApiService {
  // Base URL for the backend API
  // Change this to the backend URL when deployed
  static String get baseUrl => AppEnv.baseUrlWithLan(AppRole.admin);

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Store auth token
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // ============================================
  // DASHBOARD ANALYTICS ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/dashboard-stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load dashboard stats: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching dashboard stats: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWorkOrderTrends({int days = 7}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/work-order-trends?days=$days'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load work order trends: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching work order trends: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCategoryBreakdown() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/category-breakdown'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load category breakdown: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching category breakdown: $e');
      rethrow;
    }
  }

  // ============================================
  // STAFF MANAGEMENT ENDPOINTS
  // ============================================

  Future<List<dynamic>> getStaffMembers({
    String? department,
    bool availableOnly = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (department != null) queryParams['department'] = department;
      if (availableOnly) queryParams['available_only'] = 'true';

      final uri = Uri.parse(
        '$baseUrl/users/staff',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception('Failed to load staff members: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching staff members: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> assignStaffToConcernSlip(
    String concernSlipId,
    String staffUserId,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/concern-slips/$concernSlipId/assign-staff'),
        headers: _headers,
        body: json.encode({'assigned_to': staffUserId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to assign staff to concern slip: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('[v0] Error assigning staff to concern slip: $e');
      rethrow;
    }
  }

  // ============================================
  // CONCERN SLIPS ENDPOINTS
  // ============================================

  Future<List<dynamic>> getAllConcernSlips() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/concern-slips/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception('Failed to load concern slips: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching concern slips: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getPendingConcernSlips() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/concern-slips/pending/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception(
          'Failed to load pending concern slips: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching pending concern slips: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getConcernSlipsByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/concern-slips/status/$status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception(
          'Failed to load concern slips by status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching concern slips by status: $e');
      rethrow;
    }
  }

  // ============================================
  // JOB SERVICES ENDPOINTS
  // ============================================

  Future<List<dynamic>> getAllJobServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/job-services/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception('Failed to load job services: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching job services: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getJobServicesByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/job-services/status/$status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception(
          'Failed to load job services by status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching job services by status: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getJobService(String jobServiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/job-services/$jobServiceId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load job service: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching job service: $e');
      rethrow;
    }
  }

  // ============================================
  // WORK ORDER PERMITS ENDPOINTS
  // ============================================

  Future<List<dynamic>> getAllWorkOrderPermits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/work-order-permits/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception(
          'Failed to load work order permits: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching work order permits: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getWorkOrderPermitsByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/work-order-permits/status/$status'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception(
          'Failed to load work order permits by status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching work order permits by status: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getPendingWorkOrderPermits() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/work-order-permits/pending/all'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception(
          'Failed to load pending work order permits: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching pending work order permits: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWorkOrderPermit(String permitId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/work-order-permits/$permitId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load work order permit: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching work order permit: $e');
      rethrow;
    }
  }

  // ============================================
  // MAINTENANCE CALENDAR ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> getMaintenanceTasks({
    required String buildingId,
    String? status,
    String? assignedTo,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParams = <String, String>{
        'building_id': buildingId,
        if (status != null) 'status': status,
        if (assignedTo != null) 'assigned_to': assignedTo,
        if (dateFrom != null) 'date_from': dateFrom.toIso8601String(),
        if (dateTo != null) 'date_to': dateTo.toIso8601String(),
      };

      final uri = Uri.parse(
        '$baseUrl/maintenance-calendar/tasks',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load maintenance tasks: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching maintenance tasks: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCalendarSummary({
    required String buildingId,
    String period = 'week',
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/maintenance-calendar/calendar/summary',
      ).replace(queryParameters: {'building_id': buildingId, 'period': period});

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load calendar summary: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching calendar summary: $e');
      rethrow;
    }
  }

  // ============================================
  // AUTHENTICATION ENDPOINTS
  // ============================================

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['access_token'] != null) {
          setAuthToken(data['access_token']);
        }
        return data;
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error during login: $e');
      rethrow;
    }
  }

  // ============================================
  // HEALTH CHECK
  // ============================================

  Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error during health check: $e');
      rethrow;
    }
  }

  // ============================================
  // USER MANAGEMENT ENDPOINTS
  // ============================================

  /// Get all users with optional filters
  Future<List<dynamic>> getUsers({
    String? role,
    String? buildingId,
    String? status,
    String? department,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        if (role != null) 'role': role,
        if (buildingId != null) 'building_id': buildingId,
        if (status != null) 'status': status,
        if (department != null) 'department': department,
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/users/',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching users: $e');
      rethrow;
    }
  }

  /// Get a specific user by user_id (e.g., T-0001, S-0001, A-0001)
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching user: $e');
      rethrow;
    }
  }

  /// Update user information
  Future<Map<String, dynamic>> updateUser(
    String userId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers,
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error updating user: $e');
      rethrow;
    }
  }

  /// Update user status (active, suspended, inactive)
  Future<Map<String, dynamic>> updateUserStatus(
    String userId,
    String status,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId/status'),
        headers: _headers,
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update user status: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error updating user status: $e');
      rethrow;
    }
  }

  /// Delete or deactivate a user
  Future<Map<String, dynamic>> deleteUser(
    String userId, {
    bool permanent = false,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/users/$userId',
      ).replace(queryParameters: {'permanent': permanent.toString()});

      final response = await http.delete(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error deleting user: $e');
      rethrow;
    }
  }

  /// Bulk update user status
  Future<Map<String, dynamic>> bulkUpdateUserStatus(
    List<String> userIds,
    String newStatus,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/bulk/status'),
        headers: _headers,
        body: json.encode({'user_ids': userIds, 'new_status': newStatus}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to bulk update users: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error in bulk update: $e');
      rethrow;
    }
  }
}
