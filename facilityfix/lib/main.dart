import 'package:facilityfix/admin/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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