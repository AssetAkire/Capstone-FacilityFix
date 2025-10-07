import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';
import '../services/api_service.dart';

class AdminWebAnalyticsPage extends StatefulWidget {
  const AdminWebAnalyticsPage({super.key});

  @override
  State<AdminWebAnalyticsPage> createState() => _AdminWebAnalyticsPageState();
}

class _AdminWebAnalyticsPageState extends State<AdminWebAnalyticsPage> {
  // ============================================
  // STATE VARIABLES FOR FILTERS AND DATA
  // ============================================
  String selectedDateRange = 'This Week';
  String selectedStatus = 'All';
  String selectedDowntimeUnit = 'This Month';

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;

  // Real data from backend
  Map<String, dynamic>? _dashboardStats;
  Map<String, dynamic>? _categoryBreakdown;
  Map<String, dynamic>? _heatMapData;
  Map<String, dynamic>? _workOrderTrends;

  // Computed statistics
  int _totalRequests = 0;
  int _openIssues = 0;
  int _resolvedToday = 0;
  double _resolutionTime = 0.0;
  Map<String, int> _categoryData = {};
  Map<String, List<HeatMapData>> _buildingHeatMap = {};

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('[v0] Fetching analytics data...');

      // Fetch data in parallel
      final results = await Future.wait([
        _apiService.getDashboardStats(),
        _apiService.getCategoryBreakdown(),
        _apiService.getHeatMapData(days: _getDaysFromDateRange()),
        _apiService.getWorkOrderTrends(days: _getDaysFromDateRange()),
      ]);

      _dashboardStats = results[0];
      _categoryBreakdown = results[1];
      _heatMapData = results[2];
      _workOrderTrends = results[3];

      print('[v0] Dashboard stats: $_dashboardStats');
      print('[v0] Category breakdown: $_categoryBreakdown');
      print('[v0] Heat map data: $_heatMapData');

      // Process the data
      _processAnalyticsData();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('[v0] Error fetching analytics data: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load analytics data: ${e.toString()}';
      });
    }
  }

  int _getDaysFromDateRange() {
    switch (selectedDateRange) {
      case 'This Week':
        return 7;
      case 'This Month':
        return 30;
      case 'Last Month':
        return 30;
      case 'Last 3 Months':
        return 90;
      default:
        return 30;
    }
  }

  void _processAnalyticsData() {
    // Process dashboard stats
    if (_dashboardStats != null) {
      _totalRequests = _dashboardStats!['total_requests'] ?? 0;
      _openIssues = _dashboardStats!['pending_concerns'] ?? 0;
      _resolvedToday =
          0; // Would need additional endpoint for today's completions
      _resolutionTime =
          2.4; // Would need to calculate from job completion times
    }

    // Process category breakdown
    if (_categoryBreakdown != null) {
      final categories =
          _categoryBreakdown!['categories'] as Map<String, dynamic>?;
      if (categories != null) {
        _categoryData = categories.map(
          (key, value) => MapEntry(key, value as int),
        );
      }
    }

    // Process heat map data
    if (_heatMapData != null) {
      _buildingHeatMap = _processHeatMapData(_heatMapData!);
    }
  }

  Map<String, List<HeatMapData>> _processHeatMapData(
    Map<String, dynamic> heatMapData,
  ) {
    final Map<String, List<HeatMapData>> result = {};

    final heatMapMatrix = heatMapData['heat_map_matrix'] as List<dynamic>?;
    if (heatMapMatrix == null) {
      return _getDefaultHeatMapData(); // Fallback to mock data
    }

    // Group by floor/location
    for (var locationData in heatMapMatrix) {
      final location = locationData['location'] as String;
      final categories = locationData['categories'] as Map<String, dynamic>;

      // Calculate total issues for this location
      final totalIssues = categories.values.fold<int>(
        0,
        (sum, count) => sum + (count as int),
      );

      // Determine color based on issue count
      Color color;
      if (totalIssues == 0) {
        color = Colors.green;
      } else if (totalIssues <= 2) {
        color = Colors.yellow;
      } else if (totalIssues <= 4) {
        color = Colors.orange;
      } else {
        color = Colors.red;
      }

      // Extract floor number and unit from location (e.g., "Floor 1 - Unit 101")
      final parts = location.split(' - ');
      final floorKey = parts.isNotEmpty ? parts[0] : location;
      final unitNumber =
          parts.length > 1 ? parts[1].replaceAll('Unit ', '') : location;

      if (!result.containsKey(floorKey)) {
        result[floorKey] = [];
      }

      result[floorKey]!.add(HeatMapData(unitNumber, totalIssues, color));
    }

    // If no data, return default
    if (result.isEmpty) {
      return _getDefaultHeatMapData();
    }

    return result;
  }

  Map<String, List<HeatMapData>> _getDefaultHeatMapData() {
    return {
      'Floor 1': [
        HeatMapData('101', 0, Colors.green),
        HeatMapData('102', 0, Colors.green),
        HeatMapData('103', 0, Colors.green),
        HeatMapData('104', 0, Colors.green),
        HeatMapData('105', 0, Colors.green),
        HeatMapData('106', 0, Colors.green),
      ],
    };
  }

  // Helper function to convert routeKey to actual route path
  String? _getRoutePath(String routeKey) {
    final Map<String, String> pathMap = {
      'dashboard': '/dashboard',
      'user_users': '/user/users',
      'user_roles': '/user/roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': '/calendar',
      'inventory_items': '/inventory/items',
      'inventory_request': '/inventory/request',
      'analytics': '/analytics',
      'announcement': '/announcement',
      'settings': '/settings',
    };
    return pathMap[routeKey];
  }

  // Handle logout functionality
  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/');
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    return FacilityFixLayout(
      currentRoute: 'analytics',
      onNavigate: (routeKey) {
        final routePath = _getRoutePath(routeKey);
        if (routePath != null) {
          context.go(routePath);
        } else if (routeKey == 'logout') {
          _handleLogout(context);
        }
      },
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchAnalyticsData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ============================================
                    // TOP ROW: ANALYTICS STATISTICS CARDS
                    // ============================================
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 800) {
                          // Stack cards vertically on smaller screens
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAnalyticsCard(
                                      'TOTAL REQUEST',
                                      _totalRequests.toString(),
                                      '6.7% from last month',
                                      true,
                                      Colors.blue,
                                      Icons.inventory_2_outlined,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildAnalyticsCard(
                                      'OPEN ISSUE',
                                      _openIssues.toString(),
                                      '8% from last week',
                                      false,
                                      Colors.yellow[700]!,
                                      Icons.layers_outlined,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAnalyticsCard(
                                      'RESOLVED TODAY',
                                      _resolvedToday.toString(),
                                      '24% from yesterday',
                                      true,
                                      Colors.green,
                                      Icons.check_circle_outline,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildAnalyticsCard(
                                      'RESOLUTION TIME',
                                      '${_resolutionTime.toStringAsFixed(1)} days',
                                      '18% improvement',
                                      true,
                                      Colors.red,
                                      Icons.trending_up,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else {
                          // Show all cards in a row on larger screens
                          return Row(
                            children: [
                              Expanded(
                                child: _buildAnalyticsCard(
                                  'TOTAL REQUEST',
                                  _totalRequests.toString(),
                                  '6.7% from last month',
                                  true,
                                  Colors.blue,
                                  Icons.inventory_2_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAnalyticsCard(
                                  'OPEN ISSUE',
                                  _openIssues.toString(),
                                  '8% from last week',
                                  false,
                                  Colors.yellow[700]!,
                                  Icons.layers_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAnalyticsCard(
                                  'RESOLVED TODAY',
                                  _resolvedToday.toString(),
                                  '24% from yesterday',
                                  true,
                                  Colors.green,
                                  Icons.check_circle_outline,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildAnalyticsCard(
                                  'RESOLUTION TIME',
                                  '${_resolutionTime.toStringAsFixed(1)} days',
                                  '18% improvement',
                                  true,
                                  Colors.red,
                                  Icons.trending_up,
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // ============================================
                    // FILTER CONTROLS ROW
                    // ============================================
                    _buildFilterControls(),
                    const SizedBox(height: 24),

                    // ============================================
                    // MIDDLE ROW: HEAT MAP + PIE CHART
                    // ============================================
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 1000) {
                          // Stack vertically on smaller screens
                          return Column(
                            children: [
                              _buildBuildingHeatMap(),
                              const SizedBox(height: 20),
                              _buildTopIssueChart(),
                            ],
                          );
                        } else {
                          // Side by side on larger screens
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildBuildingHeatMap()),
                              const SizedBox(width: 20),
                              Expanded(flex: 1, child: _buildTopIssueChart()),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // ============================================
                    // BOTTOM ROW: DOWNTIME TRACKING CHART
                    // ============================================
                    _buildDowntimeTrackingChart(),
                  ],
                ),
              ),
    );
  }

  // ============================================
  // ANALYTICS STATISTICS CARD WIDGET
  // ============================================
  Widget _buildAnalyticsCard(
    String title,
    String value,
    String subtitle,
    bool isIncrease,
    Color color,
    IconData icon,
  ) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Title and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const Spacer(),

          // Main Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          // Bottom Row: Percentage and Subtitle
          Row(
            children: [
              Icon(
                isIncrease ? Icons.trending_up : Icons.trending_down,
                color: isIncrease ? Colors.green : Colors.red,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isIncrease ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // FILTER CONTROLS WIDGET
  // ============================================
  Widget _buildFilterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side filters
        Row(
          children: [
            // Date Range Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isDense: true,
                  value: selectedDateRange,
                  items:
                      [
                        'This Week',
                        'This Month',
                        'Last Month',
                        'Last 3 Months',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('Date Range: $value'),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDateRange = newValue!;
                    });
                    _fetchAnalyticsData();
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Status Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isDense: true,
                  value: selectedStatus,
                  items:
                      ['All', 'Open', 'In Progress', 'Resolved', 'Closed'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('Status: $value'),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                    _fetchAnalyticsData();
                  },
                ),
              ),
            ),
          ],
        ),

        // Right side buttons
        Row(
          children: [
            // Refresh Button
            TextButton.icon(
              onPressed: () {
                _fetchAnalyticsData();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
            const SizedBox(width: 12),

            // Export Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement export functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Export functionality coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.file_download, size: 18),
              label: const Text('Export'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // BUILDING HEAT MAP WIDGET
  // ============================================
  Widget _buildBuildingHeatMap() {
    final heatMapData =
        _buildingHeatMap.isNotEmpty
            ? _buildingHeatMap
            : _getDefaultHeatMapData();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Building Heat Map',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Heat Map Grid
            Column(
              children:
                  heatMapData.entries.map((floorEntry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          // Floor Label
                          SizedBox(
                            width: 60,
                            child: Text(
                              floorEntry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Room Units
                          Expanded(
                            child: Row(
                              children:
                                  floorEntry.value.map((unit) {
                                    return Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 4),
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: unit.color,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            unit.unitNumber,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),

            // Heat Map Legend
            const Text(
              'Showing repair request per unit',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegendItem(Colors.green, '0 requests'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.yellow, '1-2 requests'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.orange, '2-3 requests'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.red, '3+ requests'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // LEGEND ITEM HELPER WIDGET
  // ============================================
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // ============================================
  // TOP ISSUE BY CATEGORY PIE CHART WIDGET
  // ============================================
  Widget _buildTopIssueChart() {
    final categoryData =
        _categoryData.isNotEmpty
            ? _categoryData
            : {
              'HVAC': 28,
              'Electrical': 15,
              'Civil/Carpentry': 10,
              'Plumbing': 10,
              'Others': 10,
            };

    // Calculate total for percentages
    final total = categoryData.values.fold<int>(0, (sum, count) => sum + count);

    // Define colors for categories
    final categoryColors = {
      'HVAC': Colors.blue,
      'hvac': Colors.blue,
      'Electrical': Colors.orange,
      'electrical': Colors.orange,
      'Civil/Carpentry': Colors.red,
      'carpentry': Colors.red,
      'Plumbing': Colors.yellow,
      'plumbing': Colors.yellow,
      'Others': Colors.green,
      'general': Colors.green,
      'pest control': Colors.purple,
      'masonry': Colors.brown,
      'security': Colors.indigo,
      'fire_safety': Colors.deepOrange,
    };

    // Create pie chart sections
    final sections =
        categoryData.entries.map((entry) {
          final color =
              categoryColors[entry.key] ??
              categoryColors[entry.key.toLowerCase()] ??
              Colors.grey;
          final percentage = total > 0 ? (entry.value / total * 100) : 0;

          return PieChartSectionData(
            color: color,
            value: entry.value.toDouble(),
            title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Issue by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Pie Chart
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  sections: sections,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Chart Legend with Statistics
            const Text(
              'MOST PROBLEMATIC AREAS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            ...categoryData.entries.map((entry) {
              final color =
                  categoryColors[entry.key] ??
                  categoryColors[entry.key.toLowerCase()] ??
                  Colors.grey;
              final displayName = entry.key.toUpperCase();
              return _buildCategoryItem(
                displayName,
                '${entry.value} requests',
                color,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CATEGORY ITEM HELPER WIDGET
  // ============================================
  Widget _buildCategoryItem(String category, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Text(count, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  // ============================================
  // DOWNTIME TRACKING CHART WIDGET
  // ============================================
  Widget _buildDowntimeTrackingChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Downtime Tracking',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDowntimeUnit,
                      items:
                          ['This Month', 'Last Month', 'Last 3 Months'].map((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDowntimeUnit = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Area Chart
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          );
                          Widget text;
                          switch (value.toInt()) {
                            case 0:
                              text = const Text('Week 1', style: style);
                              break;
                            case 1:
                              text = const Text('Week 2', style: style);
                              break;
                            case 2:
                              text = const Text('Week 3', style: style);
                              break;
                            case 3:
                              text = const Text('Week 4', style: style);
                              break;
                            default:
                              text = const Text('', style: style);
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: text,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 3,
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    // Unit A - Green line
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 2.8),
                        FlSpot(1, 2.2),
                        FlSpot(2, 2.5),
                        FlSpot(3, 2.1),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),

                    // Unit B - Blue line
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 4.2),
                        FlSpot(1, 2.8),
                        FlSpot(2, 3.5),
                        FlSpot(3, 3.2),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),

                    // Unit C - Red line
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 4.8),
                        FlSpot(1, 4.2),
                        FlSpot(2, 4.5),
                        FlSpot(3, 4.1),
                      ],
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chart Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegendItem('Unit A', Colors.green),
                const SizedBox(width: 24),
                _buildChartLegendItem('Unit B', Colors.blue),
                const SizedBox(width: 24),
                _buildChartLegendItem('Unit C', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CHART LEGEND ITEM HELPER WIDGET
  // ============================================
  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ============================================
// HEAT MAP DATA MODEL
// Helper class to structure heat map data
// ============================================
class HeatMapData {
  final String unitNumber;
  final int requestCount;
  final Color color;

  HeatMapData(this.unitNumber, this.requestCount, this.color);
}
