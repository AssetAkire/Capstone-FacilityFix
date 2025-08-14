import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final String time;
  final bool isSender;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isSender,
  });
}

class ChatScreen extends StatelessWidget {
  final String assigneeName;
  final List<ChatMessage> messages;
  final void Function(String message) onSend;

  const ChatScreen({
    super.key,
    required this.assigneeName,
    required this.messages,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Chat Messages List
            Expanded(
              child: ListView.separated(
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Align(
                    alignment: msg.isSender
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: msg.isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 240),
                          decoration: ShapeDecoration(
                            color: msg.isSender
                                ? const Color(0xFFD3FCD2)
                                : const Color(0xFFF6F7F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            msg.text,
                            style: const TextStyle(
                              color: Color(0xFF161C24),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.71,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: msg.isSender ? 296 : null,
                          child: Text(
                            msg.time,
                            textAlign:
                                msg.isSender ? TextAlign.right : TextAlign.left,
                            style: const TextStyle(
                              color: Color(0xFF919EAB),
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Chat Input Field
            Row(
              children: [
                // Input container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF6F7F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Type a message',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Color(0xFF919EAB),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send button
                Container(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: const Color(0xFF213ED7), size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      final text = messageController.text.trim();
                      if (text.isNotEmpty) {
                        onSend(text);
                        messageController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
