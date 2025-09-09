import 'package:facilityfix/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/config/env.dart';
import 'package:facilityfix/models/scenario_models.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  late final APIService api;
  String status = 'Checking...';
  String lastReply = '-';

  @override
  void initState() {
    super.initState();
    api = APIService(); // uses AppEnv.role + resolver
    _run();
  }

  Future<void> _run() async {
    final ok = await api.testConnection();
    setState(() => status = ok ? 'Connected ✅' : 'Failed ❌');
    if (!ok) return;

    try {
      final cfg = await api.startConversation();
      final chat = await api.sendMessage(
        ChatRequest(sessionId: cfg.sessionId, message: 'Hello from ${AppEnv.role}!'),
      );
      setState(() => lastReply = chat.reply);
    } catch (e) {
      setState(() => lastReply = 'Chat failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Role: ${AppEnv.role}'),
              Text('Status: $status'),
              const SizedBox(height: 12),
              const Text('Last Reply:'),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(lastReply),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
