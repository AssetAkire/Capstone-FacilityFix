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

  Future<Map<String, dynamic>> getHeatMapData({int days = 30}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/heat-map?days=$days'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load heat map data: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching heat map data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStaffPerformanceInsights({
    int days = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/staff-performance?days=$days'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load staff performance insights: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching staff performance insights: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEquipmentInsights({int days = 90}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/equipment-insights?days=$days'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load equipment insights: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching equipment insights: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getComprehensiveAnalyticsReport({
    int days = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/analytics/comprehensive-report?days=$days'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load comprehensive analytics report: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching comprehensive analytics report: $e');
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

  /// Get a specific maintenance task by task ID
  Future<Map<String, dynamic>> getMaintenanceTaskById(String taskId) async {
    try {
      print('[v0] Fetching maintenance task: $taskId');

      final response = await http.get(
        Uri.parse('$baseUrl/maintenance-calendar/tasks/$taskId'),
        headers: _headers,
      );

      print('[v0] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load maintenance task: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching maintenance task by ID: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createMaintenanceTask(
    Map<String, dynamic> taskData,
  ) async {
    try {
      print('[v0] Creating maintenance task: ${json.encode(taskData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/maintenance-calendar/tasks'),
        headers: _headers,
        body: json.encode(taskData),
      );

      print('[v0] Response status: ${response.statusCode}');
      print('[v0] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to create maintenance task: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('[v0] Error creating maintenance task: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateMaintenanceTask(
    String taskId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/maintenance-calendar/tasks/$taskId'),
        headers: _headers,
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to update maintenance task: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error updating maintenance task: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteMaintenanceTask(String taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/maintenance-calendar/tasks/$taskId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to delete maintenance task: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error deleting maintenance task: $e');
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

  /// Get the next sequential IPM code for Internal Preventive Maintenance
  Future<String> getNextIPMCode() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/maintenance-calendar/next-ipm-code'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['code'] as String;
      } else {
        throw Exception('Failed to get next IPM code: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching next IPM code: $e');
      rethrow;
    }
  }

  /// Get the next sequential EPM code for External Preventive Maintenance
  Future<String> getNextEPMCode() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/maintenance-calendar/next-epm-code'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['code'] as String;
      } else {
        throw Exception('Failed to get next EPM code: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching next EPM code: $e');
      rethrow;
    }
  }

  /// Get the next sequential maintenance code for any maintenance type
  /// [maintenanceType] should be 'IPM', 'EPM', or other supported types
  Future<String> getNextMaintenanceCode(String maintenanceType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/maintenance-calendar/next-code/$maintenanceType'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['code'] as String;
      } else {
        throw Exception(
          'Failed to get next $maintenanceType code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching next $maintenanceType code: $e');
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
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;
      if (buildingId != null) queryParams['building_id'] = buildingId;
      if (status != null) queryParams['status'] = status;
      if (department != null) queryParams['department'] = department;
      queryParams['limit'] = limit.toString();

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

  // ============================================
  // INVENTORY MANAGEMENT ENDPOINTS
  // ============================================

  /// Create a new inventory item
  Future<Map<String, dynamic>> createInventoryItem(
    Map<String, dynamic> itemData,
  ) async {
    try {
      final backendData = {
        'building_id': itemData['building_id'],
        'item_name': itemData['item_name'],
        'item_code': itemData['item_code'],
        'classification': itemData['classification'],
        'department': itemData['department'],
        'brand_name': itemData['brand_name'],
        'current_stock': itemData['current_stock'],
        'reorder_level': itemData['reorder_level'],
        'unit_of_measure': itemData['unit'], // Map 'unit' to 'unit_of_measure'
        'is_critical': itemData['is_critical'] ?? false,
        'supplier_name':
            itemData['supplier'], // Map 'supplier' to 'supplier_name'
        if (itemData['warranty_until'] != null)
          'warranty_until': itemData['warranty_until'],
      };

      print('[v0] Sending inventory item data: ${json.encode(backendData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/inventory/items'),
        headers: _headers,
        body: json.encode(backendData),
      );

      print('[v0] Response status: ${response.statusCode}');
      print('[v0] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to create inventory item: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('[v0] Error creating inventory item: $e');
      rethrow;
    }
  }

  /// Get all inventory items for a building
  Future<Map<String, dynamic>> getInventoryItems({
    required String buildingId,
    bool includeInactive = false,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (includeInactive) queryParams['include_inactive'] = 'true';

      final uri = Uri.parse(
        '$baseUrl/inventory/buildings/$buildingId/items',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Backend returns {success: true, data: [...], count: n}
        return data;
      } else {
        throw Exception(
          'Failed to load inventory items: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching inventory items: $e');
      rethrow;
    }
  }

  /// Get a specific inventory item by ID
  Future<Map<String, dynamic>> getInventoryItem(String itemId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inventory/items/$itemId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load inventory item: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching inventory item: $e');
      rethrow;
    }
  }

  /// Update an inventory item
  Future<Map<String, dynamic>> updateInventoryItem(
    String itemId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      // Map frontend fields to backend fields
      final backendData = <String, dynamic>{};

      if (updateData.containsKey('item_name')) {
        backendData['item_name'] = updateData['item_name'];
      }
      if (updateData.containsKey('item_code')) {
        backendData['item_code'] = updateData['item_code'];
      }
      if (updateData.containsKey('classification')) {
        backendData['classification'] = updateData['classification'];
      }
      if (updateData.containsKey('department')) {
        backendData['department'] = updateData['department'];
      }
      if (updateData.containsKey('brand_name')) {
        backendData['brand_name'] = updateData['brand_name'];
      }
      if (updateData.containsKey('current_stock')) {
        backendData['current_stock'] = updateData['current_stock'];
      }
      if (updateData.containsKey('reorder_level')) {
        backendData['reorder_level'] = updateData['reorder_level'];
      }
      if (updateData.containsKey('unit')) {
        backendData['unit_of_measure'] = updateData['unit'];
      }
      if (updateData.containsKey('is_critical')) {
        backendData['is_critical'] = updateData['is_critical'];
      }
      if (updateData.containsKey('supplier')) {
        backendData['supplier_name'] = updateData['supplier'];
      }
      if (updateData.containsKey('warranty_until')) {
        backendData['warranty_until'] = updateData['warranty_until'];
      }

      print(
        '[v0] Updating inventory item $itemId: ${json.encode(backendData)}',
      );

      final response = await http.put(
        Uri.parse('$baseUrl/inventory/items/$itemId'),
        headers: _headers,
        body: json.encode(backendData),
      );

      print('[v0] Response status: ${response.statusCode}');
      print('[v0] Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to update inventory item: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('[v0] Error updating inventory item: $e');
      rethrow;
    }
  }

  /// Delete an inventory item
  Future<Map<String, dynamic>> deleteInventoryItem(String itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/inventory/items/$itemId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to delete inventory item: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error deleting inventory item: $e');
      rethrow;
    }
  }

  /// Get low stock items for a building
  Future<Map<String, dynamic>> getLowStockItems({
    required String buildingId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inventory/buildings/$buildingId/low-stock'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
          'Failed to load low stock items: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching low stock items: $e');
      rethrow;
    }
  }

  /// Get all inventory requests
  Future<Map<String, dynamic>> getInventoryRequests({
    String? buildingId,
    String? status,
    String? requestedBy,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (buildingId != null) queryParams['building_id'] = buildingId;
      if (status != null) queryParams['status'] = status;
      if (requestedBy != null) queryParams['requested_by'] = requestedBy;

      final uri = Uri.parse(
        '$baseUrl/inventory/requests',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {'success': true, 'data': data};
        }
      } else {
        throw Exception(
          'Failed to load inventory requests: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching inventory requests: $e');
      rethrow;
    }
  }

  /// Approve an inventory request
  Future<Map<String, dynamic>> approveInventoryRequest(
    String requestId, {
    int? quantityApproved,
    String? adminNotes,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (quantityApproved != null) {
        queryParams['quantity_approved'] = quantityApproved.toString();
      }
      if (adminNotes != null) {
        queryParams['admin_notes'] = adminNotes;
      }

      final uri = Uri.parse(
        '$baseUrl/inventory/requests/$requestId/approve',
      ).replace(queryParameters: queryParams);

      final response = await http.post(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to approve inventory request: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error approving inventory request: $e');
      rethrow;
    }
  }

  /// Deny an inventory request
  Future<Map<String, dynamic>> denyInventoryRequest(
    String requestId,
    String adminNotes,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/inventory/requests/$requestId/deny',
      ).replace(queryParameters: {'admin_notes': adminNotes});

      final response = await http.post(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to deny inventory request: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error denying inventory request: $e');
      rethrow;
    }
  }

  /// Fulfill an approved inventory request
  Future<Map<String, dynamic>> fulfillInventoryRequest(String requestId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inventory/requests/$requestId/fulfill'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to fulfill inventory request: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fulfilling inventory request: $e');
      rethrow;
    }
  }

  // ============================================
  // ANNOUNCEMENT ENDPOINTS
  // ============================================

  /// Get all announcements for a building
  Future<Map<String, dynamic>> getAnnouncements({
    required String buildingId,
    String audience = 'all',
    bool activeOnly = true,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'building_id': buildingId,
        'audience': audience,
        'active_only': activeOnly.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/announcements/',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load announcements: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching announcements: $e');
      rethrow;
    }
  }

  /// Get a specific announcement by ID
  Future<Map<String, dynamic>> getAnnouncement(String announcementId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcements/$announcementId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load announcement: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching announcement: $e');
      rethrow;
    }
  }

  /// Create a new announcement
  Future<Map<String, dynamic>> createAnnouncement(
    Map<String, dynamic> announcementData,
  ) async {
    try {
      print('[v0] Creating announcement: ${json.encode(announcementData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/announcements/'),
        headers: _headers,
        body: json.encode(announcementData),
      );

      print('[v0] Response status: ${response.statusCode}');
      print('[v0] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to create announcement: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('[v0] Error creating announcement: $e');
      rethrow;
    }
  }

  /// Update an announcement
  Future<Map<String, dynamic>> updateAnnouncement(
    String announcementId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      print(
        '[v0] Updating announcement $announcementId: ${json.encode(updateData)}',
      );

      final response = await http.put(
        Uri.parse('$baseUrl/announcements/$announcementId'),
        headers: _headers,
        body: json.encode(updateData),
      );

      print('[v0] Response status: ${response.statusCode}');
      print('[v0] Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to update announcement: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('[v0] Error updating announcement: $e');
      rethrow;
    }
  }

  /// Delete (deactivate) an announcement
  Future<Map<String, dynamic>> deleteAnnouncement(
    String announcementId, {
    bool notifyDeactivation = false,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/announcements/$announcementId').replace(
        queryParameters: {'notify_deactivation': notifyDeactivation.toString()},
      );

      final response = await http.delete(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to delete announcement: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error deleting announcement: $e');
      rethrow;
    }
  }

  /// Get announcement statistics for a building
  Future<Map<String, dynamic>> getAnnouncementStatistics(
    String buildingId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcements/building/$buildingId/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load announcement statistics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching announcement statistics: $e');
      rethrow;
    }
  }

  /// Get available announcement types and audiences
  Future<Map<String, dynamic>> getAnnouncementTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/announcements/types/available'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load announcement types: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching announcement types: $e');
      rethrow;
    }
  }

  // ============================================
  // NOTIFICATION ENDPOINTS
  // ============================================

  /// Get notifications for the current user
  Future<Map<String, dynamic>> getNotifications({
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'unread_only': unreadOnly.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/notifications/',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching notifications: $e');
      rethrow;
    }
  }

  /// Mark notifications as read
  Future<Map<String, dynamic>> markNotificationsAsRead(
    List<String> notificationIds,
  ) async {
    try {
      print('[v0] Marking notifications as read: $notificationIds');

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/mark-read'),
        headers: _headers,
        body: json.encode({'notification_ids': notificationIds}),
      );

      print('[v0] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to mark notifications as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error marking notifications as read: $e');
      rethrow;
    }
  }

  /// Delete a notification
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      print('[v0] Deleting notification: $notificationId');

      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: _headers,
      );

      print('[v0] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to delete notification: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error deleting notification: $e');
      rethrow;
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread/count'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['count'] as int;
      } else {
        throw Exception(
          'Failed to get unread notification count: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching unread notification count: $e');
      return 0; // Return 0 on error instead of throwing
    }
  }

  // ============================================
  // BUILDING MANAGEMENT ENDPOINTS
  // ============================================

  /// Get all buildings
  Future<List<dynamic>> getAllBuildings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/buildings/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List;
      } else {
        throw Exception('Failed to load buildings: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching buildings: $e');
      rethrow;
    }
  }

  /// Get a specific building by ID
  Future<Map<String, dynamic>> getBuilding(String buildingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/buildings/$buildingId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load building: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error fetching building: $e');
      rethrow;
    }
  }

  /// Create a new building
  Future<Map<String, dynamic>> createBuilding(
    Map<String, dynamic> buildingData,
  ) async {
    try {
      print('[v0] Creating building: ${json.encode(buildingData)}');

      final response = await http.post(
        Uri.parse('$baseUrl/buildings/'),
        headers: _headers,
        body: json.encode(buildingData),
      );

      print('[v0] Response status: ${response.statusCode}');
      print('[v0] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to create building: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('[v0] Error creating building: $e');
      rethrow;
    }
  }

  /// Update a building
  Future<Map<String, dynamic>> updateBuilding(
    String buildingId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      print('[v0] Updating building $buildingId: ${json.encode(updateData)}');

      final response = await http.put(
        Uri.parse('$baseUrl/buildings/$buildingId'),
        headers: _headers,
        body: json.encode(updateData),
      );

      print('[v0] Response status: ${response.statusCode}');
      print('[v0] Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to update building: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('[v0] Error updating building: $e');
      rethrow;
    }
  }

  /// Delete a building
  Future<Map<String, dynamic>> deleteBuilding(String buildingId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/buildings/$buildingId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete building: ${response.statusCode}');
      }
    } catch (e) {
      print('[v0] Error deleting building: $e');
      rethrow;
    }
  }

  /// Get building statistics
  Future<Map<String, dynamic>> getBuildingStatistics(String buildingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/buildings/$buildingId/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to load building statistics: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[v0] Error fetching building statistics: $e');
      rethrow;
    }
  }
}
