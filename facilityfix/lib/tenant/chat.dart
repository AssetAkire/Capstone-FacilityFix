import 'package:flutter/material.dart';
import 'package:facilityfix/tenant/announcement.dart';
import 'package:facilityfix/tenant/home.dart';
import 'package:facilityfix/tenant/profile.dart';
import 'package:facilityfix/tenant/workorder.dart';
import 'package:facilityfix/widgets/chat.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int _selectedIndex = 1;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.person),
  ];

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hello po, on the way na ako.',
      time: '10:30 AM',
      isSender: false,
    ),
    ChatMessage(
      text: 'Okay po, ingat!',
      time: '10:31 AM',
      isSender: true,
    ),
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

  void _handleSendMessage(String messageText) {
    final newMessage = ChatMessage(
      text: messageText,
      time: TimeOfDay.now().format(context),
      isSender: true,
    );
    setState(() {
      _messages.add(newMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Chat',
        leading: Row(
          children: const [
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: BackButton(),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ChatScreen(
          assigneeName: 'Juan Dela Cruz',
          messages: _messages,
          onSend: _handleSendMessage,
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
