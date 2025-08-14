import 'package:facilityfix/tenant/announcement.dart';
import 'package:facilityfix/tenant/home.dart';
import 'package:facilityfix/tenant/profile.dart';
import 'package:facilityfix/tenant/workorder.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 3;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.person),
  ];

  void _onTabTapped(int index) {
    final destinations = [
      const HomePage(),
      const WorkOrderPage(),
      const AnnouncementPage(),
      const ProfilePage(),
    ];

    if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        leading: Row(
          children: const [
            BackButton(),
            SizedBox(width: 8),
            Text('Notification'),
          ],
        ),
      ),

      body: const SafeArea(
        child: Center(
          child: Text('Notification Page'),
        ),
      ),

      bottomNavigationBar: NavBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
