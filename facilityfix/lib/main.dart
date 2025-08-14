import 'package:facilityfix/admin/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/database_test_screen.dart'; // Add this import
import 'screens/user_management_screen.dart'; // Import the new screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
// backend
      routes: {
        '/database-test': (context) => DatabaseTestScreen(),
        '/user-management':
            (context) =>
                UserManagementScreen(), // Add route for user management
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome to FacilityFix!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 20),
            Text(
              'Your facility management solution',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/database-test');
              },
              child: Text('Test Database Setup'),
            ),
            SizedBox(height: 20), // Add some spacing
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/user-management',
                ); // Button to new screen
              },
              child: Text('Test User Management'),
            ),
          ],

// front
      theme: ThemeData(
        primaryColor: const Color(0xFF005CE8),
        hintColor: const Color(0xFFF4F5FF),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(const Color(0xFFF4F5FF)),
            foregroundColor: MaterialStateProperty.all<Color>(const Color(0xFF005CE8)),
          ),
        ),
        fontFamily: 'Inter',
      ),
      home: HomePage()
    );
  }
}