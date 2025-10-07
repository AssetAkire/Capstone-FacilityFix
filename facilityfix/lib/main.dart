import 'package:facilityfix/adminweb/pages/adminwebcalendar_page.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:go_router/go_router.dart';
import 'adminweb/pages/admininventoryitems_page.dart';
import 'adminweb/pages/admininventoryrequest_page.dart';
import 'adminweb/pages/adminwebanalytics_page.dart';
import 'adminweb/pages/adminwebannouncement_page.dart';
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
import 'adminweb/pages/createwebinventoryitems_page.dart';
import 'adminweb/pages/webinventoryitems_viewdetails.dart';
import 'adminweb/pages/createwebannouncement_page.dart';
import 'adminweb/pages/adminsettings_page.dart';
import 'adminweb/pages/adminwebprofile_page.dart';
import 'adminweb/pages/loadingscreen_page.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1600, 828),   // set initial size
    center: true,            // center window
    title: "FacilityFix Admin",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setResizable(false); // disable resizing
    await windowManager.setMaximizable(false); // disable maximize button
  });
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child; // no animation
  }
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // default
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        // --- Loading Screen ---
        GoRoute(
          path: '/',
          name: 'loading',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoadingScreenPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),

        // --- Login Page with fade transition ---
        GoRoute(
          path: '/login',
          name: 'login',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              );
              return FadeTransition(opacity: curvedAnimation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const AdminWebDashPage(),
        ),
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
        // Settings route
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => AdminWebSettingsPage(
          onThemeChanged: (theme) {
            final statefulApp = context.findAncestorStateOfType<_MyAppState>();
            statefulApp?._updateTheme(theme);
          },
        ),
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
      GoRoute(
        path: '/inventory/item/create',
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
        path: '/adminweb/pages/createannouncement',
        name: 'create_announcement',
        builder: (context, state) => const CreateAnnouncementPage(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const AdminWebProfilePage(),
      ),
      // Calendar route
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const AdminWebCalendarPage(),
      ),
      // Inventory Management routes
      GoRoute(
        path: '/inventory/items',
        name: 'inventory_items',
        builder: (context, state) => const InventoryManagementItemsPage(),
      ),
      GoRoute(
        path: '/inventory/request',
        name: 'inventory_request',
        builder: (context, state) => const InventoryRequestPage(),
      ),
      
      // Analytics route
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AdminWebAnalyticsPage(),
      ),
      
      // Announcement route
      GoRoute(
        path: '/announcement',
        name: 'announcement',
        builder: (context, state) => const AdminWebAnnouncementPage(),
      ),
      
    ],
    
  );


  }

  void _updateTheme(String selectedTheme) {
    setState(() {
      if (selectedTheme == 'Light') {
        _themeMode = ThemeMode.light;
      } else if (selectedTheme == 'Dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.iOS: NoTransitionsBuilder(),
            TargetPlatform.macOS: NoTransitionsBuilder(),
            TargetPlatform.windows: NoTransitionsBuilder(),
            TargetPlatform.linux: NoTransitionsBuilder(),
            TargetPlatform.fuchsia: NoTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.dark,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: NoTransitionsBuilder(),
            TargetPlatform.iOS: NoTransitionsBuilder(),
            TargetPlatform.macOS: NoTransitionsBuilder(),
            TargetPlatform.windows: NoTransitionsBuilder(),
            TargetPlatform.linux: NoTransitionsBuilder(),
            TargetPlatform.fuchsia: NoTransitionsBuilder(),
          },
        ),
      ),
      themeMode: _themeMode,
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

  // Helper function to convert route name to routeKey used in layout
  static String _getRouteKey(String routeName) {
    final Map<String, String> routeMap = {
      'dashboard': 'dashboard',
      'user_users': 'user_users',
      'user_roles': 'user_roles',
      'work_maintenance': '/work/maintenance',
      'work_repair': '/work/repair',
      'calendar': 'calendar',
      'inventory_items': 'inventory_items',
      'inventory_request': 'inventory_request',
      'analytics': 'analytics',
      'notice': 'notice',
      'settings': 'settings',
      'logout': 'logout',
    };
    return routeMap[routeName] ?? 'dashboard';
  }
  
  // Helper function to convert routeKey to actual route path
  static String? _getRoutePath(String routeKey) {
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
      'notice': '/notice',
      'settings': '/settings',
      'logout': '/logout',
    };
    return pathMap[routeKey];
  }

  @override
  Widget build(BuildContext context) {
    final String currentRoute = GoRouterState.of(context).name ?? '';
    
    return FacilityFixLayout(
      currentRoute: _getRouteKey(currentRoute),
      onNavigate: (routeKey) {
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
}