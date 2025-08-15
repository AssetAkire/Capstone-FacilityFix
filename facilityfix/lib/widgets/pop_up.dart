import 'package:flutter/material.dart';

class CustomPopup extends StatelessWidget {
  final String title;
  final String message;
  final String primaryText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryText;
  final VoidCallback? onSecondaryPressed;
  final Widget? image;
  final IconData? icon; // icon above title
  final Color? iconColor;
  final double? iconSize;

  final IconData? primaryIcon; // icon on primary button
  final IconData? secondaryIcon; // icon on secondary button

  const CustomPopup({
    super.key,
    required this.title,
    required this.message,
    required this.primaryText,
    required this.onPrimaryPressed,
    this.secondaryText,
    this.onSecondaryPressed,
    this.image,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.primaryIcon,
    this.secondaryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: SizedBox(height: 100, width: 100, child: image),
              )
            else if (icon != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Icon(
                  icon,
                  size: iconSize ?? 80,
                  color: iconColor ?? const Color(0xFF005CE7),
                ),
              ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF393B41),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                // Primary button
                primaryIcon != null
                    ? ElevatedButton.icon(
                        icon: Icon(primaryIcon, color: Colors.white),
                        label: Text(
                          primaryText,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: const Color(0xFF005CE7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: onPrimaryPressed,
                      )
                    : ElevatedButton(
                        child: Text(
                          primaryText,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: const Color(0xFF005CE7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: onPrimaryPressed,
                      ),

                const SizedBox(height: 12),

                // Secondary button (optional)
                if (secondaryText != null)
                  secondaryIcon != null
                      ? OutlinedButton.icon(
                          icon: Icon(secondaryIcon, color: const Color(0xFF005CE7)),
                          label: Text(
                            secondaryText!,
                            style: const TextStyle(
                              color: Color(0xFF005CE7),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: Color(0xFF005CE7)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          onPressed: onSecondaryPressed,
                        )
                      : OutlinedButton(
                          child: Text(
                            secondaryText!,
                            style: const TextStyle(
                              color: Color(0xFF005CE7),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.1,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: Color(0xFF005CE7)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          onPressed: onSecondaryPressed,
                        ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
