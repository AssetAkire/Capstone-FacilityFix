import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../layout/facilityfix_layout.dart';

class AdminWebDashPage extends StatefulWidget {
  const AdminWebDashPage({super.key});

  @override
  State<AdminWebDashPage> createState() => _AdminWebDashPageState();
}

class _AdminWebDashPageState extends State<AdminWebDashPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Helper function to convert routeKey to actual route path
  String? _getRoutePath(String routeKey) {
    final Map<String, String> pathMap = {
      'dashboard': '/dashboard',
      'user_users': '/user/users',
      'user_roles': '/user/roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': '/calendar',
      'inventory_view': '/inventory/view',
      'inventory_add': '/inventory/add',
      'analytics': '/analytics',
      'notice': '/notice',
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
                context.go('/'); // Go back to login page
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
      currentRoute: 'dashboard',
      onNavigate: (routeKey) {
        final routePath = _getRoutePath(routeKey);
        if (routePath != null) {
          context.go(routePath);
        } else if (routeKey == 'logout') {
          _handleLogout(context);
        }
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // TOP ROW: STATISTICS CARDS SECTION
            // ============================================
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  // Stack cards vertically on smaller screens (Mobile/Tablet)
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'ACTIVE WORK\nORDERS',
                              '20',
                              '12 high priority',
                              '8%',
                              Colors.blue,
                              Icons.work_outline,
                              isIncrease: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'SCHEDULED\nMAINTENANCE',
                              '5',
                              'tasks this week',
                              'overdue: 3',
                              Colors.green,
                              Icons.schedule,
                              isIncrease: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'SCHEDULED REPAIR\nTASKS',
                              '40',
                              'This month',
                              '12%',
                              Colors.blue,
                              Icons.build_outlined,
                              isIncrease: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'COMPLETED TASKS',
                              '86',
                              'This month',
                              '12%',
                              Colors.red,
                              Icons.check_circle_outline,
                              isIncrease: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Show all cards in a row on larger screens (Desktop)
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'ACTIVE WORK\nORDERS',
                          '20',
                          '12 high priority',
                          '8%',
                          Colors.blue,
                          Icons.work_outline,
                          isIncrease: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'SCHEDULED\nMAINTENANCE',
                          '5',
                          'tasks this week',
                          'overdue: 3',
                          Colors.green,
                          Icons.schedule,
                          isIncrease: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'SCHEDULED REPAIR\nTASKS',
                          '40',
                          'This month',
                          '12%',
                          Colors.blue,
                          Icons.build_outlined,
                          isIncrease: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'COMPLETED TASKS',
                          '86',
                          'This month',
                          '12%',
                          Colors.red,
                          Icons.check_circle_outline,
                          isIncrease: true,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // ============================================
            // MIDDLE ROW: REPAIR TASKS TABLE + CALENDAR
            // ============================================
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1000) {
                  // Stack vertically on smaller screens
                  return Column(
                    children: [
                      _buildRepairTaskTable(),
                      const SizedBox(height: 20),
                      _buildMaintenanceCalendar(),
                    ],
                  );
                } else {
                  // Side by side on larger screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildRepairTaskTable(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 1,
                        child: _buildMaintenanceCalendar(),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // ============================================
            // BOTTOM ROW: MAINTENANCE SCHEDULE + CHART
            // ============================================
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1000) {
                  // Stack vertically on smaller screens
                  return Column(
                    children: [
                      _buildMaintenanceSchedule(),
                      const SizedBox(height: 20),
                      _buildRepairChart(),
                    ],
                  );
                } else {
                  // Side by side on larger screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildMaintenanceSchedule(),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: _buildRepairChart(),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // STATISTICS CARD WIDGET
  // ============================================
  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    String percentage,
    Color color,
    IconData icon, {
    bool isIncrease = true,
  }) {
    return Container(
      height: 140, // Increased height for better spacing
      padding: const EdgeInsets.all(18), // Increased padding
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
                    fontSize: 11, // Slightly increased font size
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8), // Increased icon padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18, // Increased icon size
                ),
              ),
            ],
          ),
          const Spacer(),
          
          // Main Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 32, // Increased main value font size
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          
          // Bottom Row: Percentage and Subtitle
          Row(
            children: [
              // Percentage indicator (if provided)
              if (percentage.isNotEmpty) ...[
                Icon(
                  isIncrease ? Icons.trending_up : Icons.trending_down,
                  color: isIncrease ? Colors.green : Colors.red,
                  size: 14, // Increased icon size
                ),
                const SizedBox(width: 4),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 11, // Increased font size
                    color: isIncrease ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Subtitle text
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11, // Increased font size
                    color: Colors.grey[600],
                    height: 1.3, // Better line height
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
  // REPAIR TASKS TABLE WIDGET
  // ============================================
  Widget _buildRepairTaskTable() {
    final tasks = [
      {
        'task': 'Clogged Drainage',
        'priority': 'High',
        'name': 'Juan Dela Cruz',
        'status': 'In Progress',
        'priorityColor': Colors.red,
        'statusColor': Colors.green,
      },
      {
        'task': 'Faulty Light Switch',
        'priority': 'Medium',
        'name': 'Arman Reyes',
        'status': 'In Review',
        'priorityColor': Colors.orange,
        'statusColor': Colors.orange,
      },
      {
        'task': 'Door Lock Issue',
        'priority': 'High',
        'name': 'Joel Ramirez',
        'status': 'Completed',
        'priorityColor': Colors.red,
        'statusColor': Colors.pink,
      },
      {
        'task': 'Broken Cabinet',
        'priority': 'Low',
        'name': 'Leo Manalo',
        'status': 'In Review',
        'priorityColor': Colors.green,
        'statusColor': Colors.orange,
      },
      {
        'task': 'Water Leak',
        'priority': 'High',
        'name': 'Marian Lim',
        'status': 'In Progress',
        'priorityColor': Colors.red,
        'statusColor': Colors.green,
      },
    ];

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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.build, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Repair Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See All',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Data Table with improved layout
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width * 0.4,
                ),
                child: DataTable(
                  columnSpacing: 24,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 48,
                  columns: [
                    'Task',
                    'Priority',
                    'Name',
                    'Status',
                  ]
                      .map((header) => DataColumn(
                            label: Text(
                              header,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  rows: tasks.map((task) => DataRow(
                        cells: [
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 150),
                              child: Text(
                                task['task'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (task['priorityColor'] as Color)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task['priority'] as String,
                                style: TextStyle(
                                  color: task['priorityColor'] as Color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                task['name'] as String,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (task['statusColor'] as Color)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                task['status'] as String,
                                style: TextStyle(
                                  color: task['statusColor'] as Color,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // MAINTENANCE CALENDAR WIDGET
  // ============================================
  Widget _buildMaintenanceCalendar() {
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
              'Maintenance Calendar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TableCalendar<void>(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: Colors.black87),
                todayDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerDecoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              eventLoader: (day) {
                // Mock events for demonstration
                if (day.day == 25 || day.day == 28) {
                  return ['maintenance'];
                }
                if (day.day == 9 || day.day == 10) {
                  return ['repair'];
                }
                return [];
              },
            ),
            const SizedBox(height: 16),
            
            // Calendar Legend
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Repair Tasks',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Maintenance',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // MAINTENANCE SCHEDULE WIDGET
  // ============================================
  Widget _buildMaintenanceSchedule() {
    final schedules = [
      {
        'title': 'Light Inspection',
        'assignee': 'Arman Reyes',
        'date': 'July 1, 2025',
      },
      {
        'title': 'Pest Control',
        'assignee': 'Juan Dela Cruz',
        'date': '2025-07-30',
      },
    ];

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
            // Schedule Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Maintenance Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Calendar',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Schedule Items
            ...schedules.map((schedule) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Schedule',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        schedule['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            schedule['assignee']!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            schedule['date']!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            
            // Add New Schedule Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Schedule new Maintenance'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // REPAIR CHART WIDGET
  // ============================================
  Widget _buildRepairChart() {
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
                  'Repair and Maintenance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Weekly',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.blue,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            //linechart
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[200]!,
                        strokeWidth: 1,
                      );
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
                              text = const Text('Sun', style: style);
                              break;
                            case 1:
                              text = const Text('Mon', style: style);
                              break;
                            case 2:
                              text = const Text('Tue', style: style);
                              break;
                            case 3:
                              text = const Text('Wed', style: style);
                              break;
                            case 4:
                              text = const Text('Thu', style: style);
                              break;
                            case 5:
                              text = const Text('Fri', style: style);
                              break;
                            case 6:
                              text = const Text('Sat', style: style);
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
                        interval: 5,
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
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 20,
                  lineBarsData: [
                    // Repair Tasks line (green)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 8),
                        FlSpot(2, 2),
                        FlSpot(3, 6),
                        FlSpot(4, 4),
                        FlSpot(5, 12),
                        FlSpot(6, 5),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.green.withOpacity(0.8), Colors.green],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Colors.green,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                    // Maintenance line (blue)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 8),
                        FlSpot(1, 12),
                        FlSpot(2, 6),
                        FlSpot(3, 14),
                        FlSpot(4, 10),
                        FlSpot(5, 16),
                        FlSpot(6, 10),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue.withOpacity(0.8), Colors.blue],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Repair Tasks',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Maintenance',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}