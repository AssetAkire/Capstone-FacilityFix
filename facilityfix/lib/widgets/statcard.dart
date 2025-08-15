import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData? icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;

  const StatusCard({
    super.key,
    required this.title,
    required this.count,
    this.icon,
    this.iconColor = const Color(0xFF475467),
    this.backgroundColor = const Color(0xFFEFF5FF),
    this.borderColor = const Color(0xFF005CE7),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475467), // Secondary text
                      fontFamily: 'Inter',
                      letterSpacing: -0.5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0xFF101828), // Primary text
                fontFamily: 'Inter',
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
