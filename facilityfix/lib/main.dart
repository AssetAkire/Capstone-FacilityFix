import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

// Pages & layout
import 'adminweb/layout/facilityfix_layout.dart';
import 'adminweb/pages/login_page.dart';
import 'adminweb/pages/adminwebdash_page.dart';
import 'adminweb/pages/adminwebuser_page.dart';
import 'adminweb/pages/adminrole_page.dart';
import 'adminweb/pages/adminmaintenance_page.dart';
import 'adminweb/pages/adminrepair_cs_page.dart';
import 'adminweb/pages/adminrepair_js_page.dart';
import 'adminweb/pages/adminrepair_wop_page.dart';
import 'adminweb/pages/workmaintenance_form.dart';
import 'adminweb/pages/internalmaintenance_viewform.dart';
import 'adminweb/pages/externalmaintenance_form.dart';
import 'adminweb/pages/externalmaintenance_viewform.dart';
import 'adminweb/pages/adminwebcalendar_page.dart';
import 'adminweb/pages/admininventoryitems_page.dart';
import 'adminweb/pages/admininventoryrequest_page.dart';
import 'adminweb/pages/adminwebanalytics_page.dart';
import 'adminweb/pages/adminwebannouncement_page.dart';
import 'adminweb/pages/createwebannouncement_page.dart';
import 'adminweb/pages/createwebinventoryitems_page.dart';
import 'adminweb/pages/webinventoryitems_viewdetails.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await windowManager.ensureInitialized();

    const options = WindowOptions(
      size: Size(1600, 828),
      center: true,
      title: 'FacilityFix Admin',
      // optional:
      // minimumSize: Size(1200, 720),
      // backgroundColor: Colors.white,
    );

    windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setResizable(false); // disable resize
      await windowManager.setMaximizable(false); // disable maximize
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // GoRouter configuration (web-safe)
  static final GoRouter _router = GoRouter(
    initialLocation: '/', // Start at login page
    routes: [
      // Login route
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Dashboard
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const AdminWebDashPage(),
      ),

      // User Management
      GoRoute(
        path: '/user/users',
        name: 'user_users',
        builder: (context, state) => const AdminUserPage(),
      ),
      GoRoute(
        path: '/user/roles',
        name: 'user_roles',
        builder: (context, state) => const AdminRolePage(),
      ),

      // Work Orders
      GoRoute(
        path: '/work/maintenance',
        name: 'work_maintenance',
        builder: (context, state) => const AdminMaintenancePage(),
      ),
      GoRoute(
        path: '/work/repair',
        name: 'work_repair_concernslip',
        builder: (context, state) => const AdminRepairPage(),
      ),

      // Calendar
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const AdminWebCalendarPage(),
      ),

      // Inventory
      GoRoute(
        path: '/inventory/items',
        name: 'inventory_items',
        builder: (context, state) => const InventoryManagementItemsPage(),
      ),
      GoRoute(
        path: '/inventory/items/create',
        name: 'inventory_item_create',
        builder: (context, state) => const InventoryItemCreatePage(),
      ),
      GoRoute(
        path: '/inventory/item/:itemId',
        name: 'inventory_item_details',
        builder: (context, state) {
          final itemId = state.pathParameters['itemId']!;
          return InventoryItemDetailsPage(itemId: itemId);
        },
      ),
      GoRoute(
        path: '/inventory/request',
        name: 'inventory_request',
        builder: (context, state) => const InventoryRequestPage(),
      ),

      // Analytics (placeholder)
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AdminWebAnalyticsPage(),
      ),

      // Announcements
      GoRoute(
        path: '/announcement',
        name: 'announcement',
        builder: (context, state) => const AdminWebAnnouncementPage(),
      ),
      GoRoute(
        path: '/announcement/create',
        name: 'announcement_create',
        builder: (context, state) => const CreateAnnouncementPage(),
      ),

      // Notice (placeholder)
      GoRoute(
        path: '/notice',
        name: 'notice',
        builder: (context, state) => const PlaceholderPage(title: 'Notice'),
      ),

      // Settings (placeholder)
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const PlaceholderPage(title: 'Settings'),
      ),

      // Logout (back to login)
      GoRoute(
        path: '/logout',
        name: 'logout',
        builder: (context, state) => const LoginPage(),
      ),

      // Forms & detail routes
      GoRoute(
        path: '/work/maintenance/create/internal',
        name: 'maintenance_create_internal',
        builder: (context, state) => const InternalMaintenanceFormPage(),
      ),
      GoRoute(
        path: '/work/maintenance/create/external',
        name: 'maintenance_create_external',
        builder: (context, state) => const ExternalMaintenanceFormPage(),
      ),
      GoRoute(
        path: '/adminweb/pages/workmaintenance_form',
        builder: (context, state) => const InternalMaintenanceFormPage(),
      ),
      GoRoute(
        path: '/work/maintenance/:id/internal',
        name: 'maintenance_internal',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final task = state.extra as Map<String, dynamic>?;
          final isEdit = state.uri.queryParameters['edit'] == '1';
          return InternalTaskViewPage(
            taskId: id,
            initialTask: task,
            startInEditMode: isEdit,
          );
        },
      ),
      GoRoute(
        path: '/adminweb/pages/externalmaintenance_form',
        name: 'maintenance_external_form',
        builder: (context, state) => const ExternalMaintenanceFormPage(),
      ),
      GoRoute(
        path: '/work/maintenance/:id/external',
        name: 'maintenance_external',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final task = state.extra as Map<String, dynamic>?;
          final isEdit = state.uri.queryParameters['edit'] == '1';
          return ExternalViewTaskPage(
            taskId: id,
            initialTask: task,
            startInEditMode: isEdit,
          );
        },
      ),

      // Repair subpages
      GoRoute(
        path: '/adminweb/pages/adminrepair_js_page',
        name: 'work_repair_jobservice',
        builder: (context, state) => const RepairJobServicePage(),
      ),
      GoRoute(
        path: '/adminweb/pages/adminrepair_wop_page',
        name: 'work_repair_workorderpermit',
        builder: (context, state) => const RepairWorkOrderPermitPage(),
      ),
    ],

    // Visible error instead of blank screen
    errorBuilder:
        (context, state) =>
            const Scaffold(body: Center(child: Text('Page not found!'))),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FacilityFix Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, fontFamily: 'Inter'),
      routerConfig: _router,
    );
  }
}

// Temporary placeholder page for routes that don't have pages yet
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).name ?? '';

    return FacilityFixLayout(
      currentRoute: _getRouteKey(currentRoute),
      onNavigate: (routeKey) {
        final routePath = _getRoutePath(routeKey);
        if (routePath != null) context.go(routePath);
      },
      body: Center(
        // <-- Remove nested Scaffold - FacilityFixLayout already provides one
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This page is under construction',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // Convert route name to routeKey used in layout
  String _getRouteKey(String routeName) {
    final Map<String, String> routeMap = {
      'dashboard': 'dashboard',
      'user_users': 'user_users',
      'user_roles': 'user_roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': 'calendar',
      'inventory_items': 'inventory_items',
      'inventory_item_create': 'inventory_item_create',
      'inventory_item_details': 'inventory_item_details',
      'inventory_request': 'inventory_request',
      'analytics': 'analytics',
      'notice': 'notice',
      'settings': 'settings',
      'logout': 'logout',
      'announcement_create': 'announcement_create',
    };
    return routeMap[routeName] ?? 'dashboard';
  }

  // Convert routeKey to an actual route path
  String? _getRoutePath(String routeKey) {
    final Map<String, String> pathMap = {
      'dashboard': '/dashboard',
      'user_users': '/user/users',
      'user_roles': '/user/roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': '/calendar',
      'inventory_items': '/inventory/items',
      'inventory_item_create': '/inventory/items/create',
      'inventory_item_details': '/inventory/item/:itemId',
      'inventory_request': '/inventory/request',
      'analytics': '/analytics',
      'notice': '/notice',
      'settings': '/settings',
      'logout': '/logout',
      'announcement_create': '/announcement/create',
    };
    return pathMap[routeKey];
  }
}

// Mobile 
// import 'package:facilityfix/landingpage/welcomepage.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF005CE8),
//         hintColor: const Color(0xFFF4F5FF),
//         iconButtonTheme: IconButtonThemeData(
//           style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFF4F5FF)),
//             foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFF005CE8)),
//           ),
//         ),
//         fontFamily: 'Inter',
//       ),
//       home: WelcomePage(), 
//     );
//   }
// }
