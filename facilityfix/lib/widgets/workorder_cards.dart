import 'package:flutter/material.dart';

class RequestRepairCard extends StatelessWidget {
  final String title;
  final String requestId;
  final String date;
  final String classification;
  final VoidCallback onTap;      
  final VoidCallback onChatTap;  
  
  const RequestRepairCard({
    super.key,
    required this.title,
    required this.requestId,
    required this.date,
    required this.classification,
    required this.onTap,
    required this.onChatTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'review':
        return const Color(0xFFFFFAEB);
      case 'done':
        return const Color(0xFFEFFCF3);
      case 'in progress':
        return const Color(0xFFFFF9EB);
      case 'approved':
        return const Color(0xFFE4E7EC);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'review':
        return const Color(0xFFF79009);
      case 'done':
        return const Color(0xFF12B76A);
      case 'in progress':
        return const Color(0xFFE9A500);
      case 'approved':
        return const Color(0xFF667085);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xFFF6F7F9),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFDDDEE0)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: ShapeDecoration(
                    color: _getStatusColor(classification),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    classification,
                    style: TextStyle(
                      color: _getTextColor(classification),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Request ID
            Text(
              requestId,
              style: const TextStyle(
                color: Color(0xFF4A5154),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 12),

            // Date & Status Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              // Profile of staff
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFD9D9D9),
                ),
                Row(

                  // Date
                  children: [
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Chat icon
                    GestureDetector(
                      onTap: onChatTap, 
                      child: Container(
                        width: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(Icons.chat_bubble_outline, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Admin repair card
class RepairTaskCard extends StatelessWidget {
  final String title;
  final String requestId;
  final String date;
  final String unit;
  final String classification;
  final VoidCallback onTap;

  const RepairTaskCard({
    super.key,
    required this.title,
    required this.requestId,
    required this.date,
    required this.unit,
    required this.classification,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'review':
        return const Color(0xFFFFFAEB);
      case 'done':
        return const Color(0xFFEFFCF3);
      case 'in progress':
        return const Color(0xFFFFF9EB);
      case 'approved':
        return const Color(0xFFE4E7EC);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'review':
        return const Color(0xFFF79009);
      case 'done':
        return const Color(0xFF12B76A);
      case 'in progress':
        return const Color(0xFFE9A500);
      case 'approved':
        return const Color(0xFF667085);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xFFF6F7F9),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFDDDEE0)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: ShapeDecoration(
                    color: _getStatusColor(classification),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    classification,
                    style: TextStyle(
                      color: _getTextColor(classification),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Request ID
            Text(
              requestId,
              style: const TextStyle(
                color: Color(0xFF4A5154),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),

            // Unit
            Text(
              unit,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),
            
            // Profile and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFD9D9D9),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Announcement task card
class MaintenanceTaskCard extends StatelessWidget {
  final String title;
  final String requestId;
  final String unit;
  final String date;
  final String classification;
  final VoidCallback onTap;
  final VoidCallback onChatTap;

  const MaintenanceTaskCard({
    super.key,
    required this.title,
    required this.requestId,
    required this.unit,
    required this.date,
    required this.classification,
    required this.onTap,
    required this.onChatTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFFEFFCF3);
      case 'in progress':
        return const Color(0xFFE4E7EC);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF12B76A);
      case 'in progress':
        return const Color(0xFF667085);
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: const Color(0xFFF6F7F9),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFDDDEE0)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: ShapeDecoration(
                    color: _getStatusColor(classification),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    classification,
                    style: TextStyle(
                      color: _getTextColor(classification),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Request ID
            Text(
              requestId,
              style: const TextStyle(
                color: Color(0xFF4A5154),
                fontSize: 14,
              ),
            ),

            // Unit
            Text(
              unit,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Footer: Profile + Date + Chat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Placeholder profile (you can replace with actual profile picture)
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFD9D9D9),
                ),

                // Date and Chat
                Row(
                  children: [
                    // Date badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Chat icon
                    GestureDetector(
                      onTap: onChatTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(Icons.chat_bubble_outline, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
