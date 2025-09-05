
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'adminweb/pages/login_page.dart';
import 'adminweb/pages/adminwebdash_page.dart';
import 'adminweb/layout/facilityfix_layout.dart';
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // GoRouter configuration
  final GoRouter _router = GoRouter(
    initialLocation: '/', // Start at login page
    routes: [
      // Login route
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // Dashboard route - using your existing AdminWebDashPage
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const AdminWebDashPage(),
      ),
      
      // User Management routes
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
      
      // Work Order routes
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
      
      // Calendar route
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const PlaceholderPage(title: 'Calendar'),
      ),
      
      // Inventory Management routes
      GoRoute(
        path: '/inventory/view',
        name: 'inventory_view',
        builder: (context, state) => const PlaceholderPage(title: 'View Inventory'),
      ),
      GoRoute(
        path: '/inventory/add',
        name: 'inventory_add',
        builder: (context, state) => const PlaceholderPage(title: 'Add Inventory'),
      ),
      
      // Analytics route
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const PlaceholderPage(title: 'Analytics'),
      ),
      
      // Notice route
      GoRoute(
        path: '/notice',
        name: 'notice',
        builder: (context, state) => const PlaceholderPage(title: 'Notice'),
      ),
      
      // Settings route
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const PlaceholderPage(title: 'Settings'),
      ),
      
      // Logout route (can redirect back to login)
      GoRoute(
        path: '/logout',
        name: 'logout',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/adminweb/pages/workmaintenance_form',
        builder: (context, state) => const InternalMaintenanceFormPage(),
      ),
      GoRoute(
        path: '/workmaintenance/internalviewtask',
        name: 'maintenance_internal',
        builder: (context, state) => const InternalTaskViewPage(),
      ),
      GoRoute(
        path: '/adminweb/pages/externalmaintenance_form',
        name: 'maintenance_external_form',
        builder: (context, state) => const ExternalMaintenanceFormPage(),
      ),
      GoRoute(
        path: '/adminweb/pages/externalviewtask',
        name: 'maintenance_external',
        builder: (context, state) => const ExternalViewTaskPage(),
      ),
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
    
    // Optional: Handle navigation errors
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found!'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FacilityFix Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      routerConfig: _router,
    );
  }
}

// Temporary placeholder page for routes that don't have pages yet
class PlaceholderPage extends StatelessWidget {
  final String title;
  
  const PlaceholderPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Get current route to pass to layout
    final String currentRoute = GoRouterState.of(context).name ?? '';
    
    return FacilityFixLayout(
      currentRoute: _getRouteKey(currentRoute),
      onNavigate: (routeKey) {
        // Convert routeKey to actual route path
        final routePath = _getRoutePath(routeKey);
        if (routePath != null) {
          context.go(routePath);
        }
      },
      body: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This page is under construction',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper function to convert route name to routeKey used in layout
  String _getRouteKey(String routeName) {
    final Map<String, String> routeMap = {
      'dashboard': 'dashboard',
      'user_users': 'user_users',
      'user_roles': 'user_roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': 'calendar',
      'inventory_view': 'inventory_view',
      'inventory_add': 'inventory_add',
      'analytics': 'analytics',
      'notice': 'notice',
      'settings': 'settings',
      'logout': 'logout',
    };
    return routeMap[routeName] ?? 'dashboard';
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
      'inventory_view': '/inventory/view',
      'inventory_add': '/inventory/add',
      'analytics': '/analytics',
      'notice': '/notice',
      'settings': '/settings',
      'logout': '/logout',
    };
    return pathMap[routeKey];
  }
}

// =======
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF005CE8),
//         hintColor: const Color(0xFFF4F5FF),
//         iconButtonTheme: IconButtonThemeData(
//           style: ButtonStyle(
//             backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFF4F5FF)),
//             foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFF005CE8)),
// >>>>>>> raf-branch
//           ),
//         ),
//         fontFamily: 'Inter',
//       ),
// <<<<<<< main
//     );
//   }