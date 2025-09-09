import 'package:facilityfix/widgets/buttons.dart' as custom_buttons;
import 'package:facilityfix/widgets/forms.dart';
import 'package:flutter/material.dart';

import 'profile.dart';

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


/// ============================ Restock Bottom Sheet ============================

class RestockResult {
  final String quantity;
  final String unit; // always provided by details

  const RestockResult({
    required this.quantity,
    required this.unit,
  });
}

class RestockBottomSheet extends StatefulWidget {
  final String itemName;
  final String itemId;
  final String unit; // ⬅️ auto from details

  const RestockBottomSheet({
    super.key,
    required this.itemName,
    required this.itemId,
    required this.unit,
  });

  @override
  State<RestockBottomSheet> createState() => _RestockBottomSheetState();
}

class _RestockBottomSheetState extends State<RestockBottomSheet> {
  final TextEditingController _qtyCtrl = TextEditingController();

  bool get _isValid {
    final q = _qtyCtrl.text.trim();
    final asNum = double.tryParse(q);
    return q.isNotEmpty && asNum != null && asNum > 0;
  }

  @override
  void initState() {
    super.initState();
    _qtyCtrl.addListener(_refresh);
  }

  @override
  void dispose() {
    _qtyCtrl.removeListener(_refresh);
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Material(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grabber
                const SizedBox(height: 8),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),

                // Header with item identity
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        widget.itemName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.itemId,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quantity (only) + Auto Unit pill (read-only)
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w700,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _qtyCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  hintText: 'e.g., 50',
                                  isDense: true,
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFD1D5DB)), // default gray
                                  ),
                                  // ✅ highlight blue when focused
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF005CE7),
                                      width: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF4FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD1D5DB)),
                              ),
                              child: Text(
                                widget.unit, // auto unit from details
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Color(0xFF344054),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== Bottom actions =====
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            fixedSize: const Size.fromHeight(48),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Color(0xFFD0D5DD)),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF005CE7),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            opacity: _isValid ? 1.0 : 0.5,
                            child: IgnorePointer(
                              ignoring: !_isValid, // block taps when "disabled"
                              child: custom_buttons.FilledButton(
                                label: 'Restock',
                                backgroundColor: const Color(0xFF005CE7),
                                textColor: Colors.white,
                                withOuterBorder: false,
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                    RestockResult(
                                      quantity: _qtyCtrl.text.trim(),
                                      unit: widget.unit, // auto unit
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
