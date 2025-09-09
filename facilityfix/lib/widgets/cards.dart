import 'package:facilityfix/widgets/helper_models.dart';
import 'package:facilityfix/widgets/tag.dart';
import 'package:facilityfix/widgets/view_details.dart';
import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData? icon;
  final Color iconColor;
  final Color backgroundColor; // base for gradient
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
    final Color gStart = Color.lerp(backgroundColor, Colors.white, 0.88)!;
    final Color gEnd   = Color.lerp(backgroundColor, Colors.white, 0.70)!;

    return Material(
      color: Colors.transparent,
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gStart, gEnd],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withOpacity(0.45), width: 1),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias, // ensures glow respects rounded corners
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475467),
                            fontFamily: 'Inter',
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        // Count
                        Text(
                          count,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 1.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101828),
                            fontFamily: 'Inter',
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icon (no border, just clean)
                  if (icon != null) ...[
                    const SizedBox(width: 12),
                    Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Center(
                          child: Icon(icon, size: 30, color: iconColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Announcement Card -----------------------------
class AnnouncementCard extends StatelessWidget {
  final String title;
  final String datePosted;   // e.g., "Aug 7, 2025"
  final String details;
  final String classification; // e.g., "utility interruption", "power outage", "pest control", "maintenance"
  final VoidCallback onTap;

  /// Optional knobs
  final int maxDetailLines;
  final bool showChevron;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.datePosted,
    required this.details,
    required this.classification,
    required this.onTap,
    this.maxDetailLines = 3,
    this.showChevron = true,
  });

  // Right-side-only radius used everywhere (Material, InkWell, Container)
  static const BorderRadius _rightOnly = BorderRadius.only(
    topRight: Radius.circular(16),
    bottomRight: Radius.circular(16),
  );

  // Normalize classification for map lookups
  String _norm(String s) => s.trim().toLowerCase();

  _ClassStyle get _style {
    final key = _norm(classification);
    return _styles[key] ?? _styles['default']!;
  }

  // Title Case helper for badge text
  String _titleCase(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    return parts
        .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Material(
      color: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: _rightOnly),
      clipBehavior: Clip.antiAlias, // ripple respects right-only radius
      child: InkWell(
        onTap: onTap,
        customBorder: const RoundedRectangleBorder(borderRadius: _rightOnly),
        child: Stack(
          children: [
            // Card container (right-only rounded)
            Container(
              decoration: BoxDecoration(
                color: style.tint,
                borderRadius: _rightOnly,
                border: Border.all(color: style.accent.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: title + (optional chevron)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF101828),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            ),
                            if (showChevron) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.chevron_right, color: style.accent, size: 22),
                            ],
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Meta row: classification badge + date
                        Row(
                          children: [
                            // classification pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: style.badgeBg,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: style.accent.withOpacity(0.35)),
                              ),
                              child: Text(
                                _titleCase(classification),
                                style: TextStyle(
                                  color: style.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Posted $datePosted',
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Details/preview
                        Text(
                          details,
                          maxLines: maxDetailLines,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF475467),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Left accent bar (straight edge; no rounding on the left)
            Positioned.fill(
              left: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 4,
                  color: style.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- Classification color system ------------------------------------------

class _ClassStyle {
  final Color accent;  // strong accent (bar/badge text)
  final Color tint;    // soft background
  final Color badgeBg; // pill background

  const _ClassStyle({
    required this.accent,
    required this.tint,
    required this.badgeBg,
  });
}

// Palette map (extend as needed)
const Map<String, _ClassStyle> _styles = {
  // Utility / water interruptions (blue)
  'utility interruption': _ClassStyle(
    accent: Color(0xFF005CE7),
    tint: Color(0xFFEFF4FF),
    badgeBg: Color(0xFFF4F5FF),
  ),

  // Power outage (amber)
  'power outage': _ClassStyle(
    accent: Color(0xFFF79009),
    tint: Color(0xFFFFF7E8),
    badgeBg: Color(0xFFFFFAEB),
  ),

  // Pest control (green)
  'pest control': _ClassStyle(
    accent: Color(0xFF12B76A),
    tint: Color(0xFFEAFBF3),
    badgeBg: Color(0xFFE8F7F1),
  ),

  // Maintenance (indigo/purple)
  'general maintenance': _ClassStyle(
    accent: Color(0xFF7A5AF8),
    tint: Color(0xFFF4F5FF),
    badgeBg: Color(0xFFF4F5FF),
  ),

  // Fallback neutral
  'default': _ClassStyle(
    accent: Color(0xFF667085),
    tint: Color(0xFFF2F4F7),
    badgeBg: Color(0xFFF7F9FC),
  ),
};

// Inventory Card -----------------------------------------
class InventoryCard extends StatefulWidget {
  final String itemName;
  final String stockStatus; // e.g., In Stock | Out of Stock | Critical
  final String itemId;
  final String department;  // e.g., Plumbing, Electrical, etc.
  final String quantityInStock;    // keep as String to match your source
  final VoidCallback? onTap;

  const InventoryCard({
    super.key,
    required this.itemName,
    required this.stockStatus,
    required this.itemId,
    required this.department,
    required this.quantityInStock,
    this.onTap,
  });

  @override
  State<InventoryCard> createState() => _InventoryCardState();
}

class _InventoryCardState extends State<InventoryCard> {
  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: widget.onTap ??
            () => debugPrint('InventoryCard tapped: ${widget.itemId}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(
              width: 1,
              color: Colors.black.withOpacity(0.08),
            ),
            // ⬇︎ removed boxShadow
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Stock status tag
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF101828),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StockStatusTag(widget.stockStatus),
                ],
              ),

              const SizedBox(height: 6),

              // Item ID (muted)
              Text(
                'ID: ${widget.itemId}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF4A5154),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // Department tag + Quantity pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DepartmentTag(widget.department),
                  _QuantityPill(quantity: widget.quantityInStock),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small, reusable quantity chip for consistent look
class _QuantityPill extends StatelessWidget {
  final String quantity;
  const _QuantityPill({required this.quantity});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 84),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: StadiumBorder(
          side: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2, size: 14, color: Color(0xFF101828)),
          const SizedBox(width: 6),
          Text(
            quantity,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF101828),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ========= Inventory Request Card =========

class InventoryRequestCard extends StatelessWidget {
  final String itemName;
  final String requestId;
  final String department; // e.g., "Electrical", "Plumbing"
  final String status;     // e.g., "Pending", "Approved", "Rejected"
  final VoidCallback? onTap;

  const InventoryRequestCard({
    super.key,
    required this.itemName,
    required this.requestId,
    required this.department,
    required this.status,
    this.onTap,
  });

  // Visual tokens (aligned with InventoryCard)
  static const _textPrimary   = Color(0xFF101828);
  static const _textSecondary = Color(0xFF4A5154);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: radius,
            border: Border.all(width: 1, color: Colors.black.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Status tag (right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusTag(status: status, width: 96), // ← calls your StatusTag
                ],
              ),

              const SizedBox(height: 6),

              // ID line
              Text(
                'ID: $requestId',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: _textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // Department chip (left-aligned, like InventoryCard)
              DepartmentTag(department),
            ],
          ),
        ),
      ),
    );
  }
}


// Notification Message card
class NotificationMessageCard extends StatelessWidget {
  const NotificationMessageCard({
    super.key,
    required this.title,
    required this.message,
    required this.timeLabel,
    this.isUnread = false,
    this.onTap,
    this.leading,
    this.borderColor = const Color(0xFFE5E7E8),
    this.unreadTint = const Color(0xFFF7F9FF),
    this.titleColor = Colors.black,
    this.subtitleColor = const Color(0xFF515978),
    this.radius = 12,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    this.maxMessageLines = 3,
    this.showUnreadDot = true,
  });

  final String title;
  final String message;
  final String timeLabel;
  final bool isUnread;
  final VoidCallback? onTap;
  final Widget? leading;

  final Color borderColor;
  final Color unreadTint;
  final Color titleColor;
  final Color subtitleColor;

  final double radius;
  final EdgeInsets contentPadding;
  final int maxMessageLines;
  final bool showUnreadDot;

  @override
  Widget build(BuildContext context) {
    final cardBg = isUnread ? unreadTint : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: ShapeDecoration(
            color: cardBg,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1, color: borderColor),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          padding: contentPadding,
          child: Row(
            // 🔧 DO NOT USE stretch in a ListView/Sliver context
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                // Keep a finite size; never use double.infinity here
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: leading!,
                ),
              ],
              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Title + Time (+ optional unread dot)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              height: 1.3,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeLabel,
                              style: TextStyle(
                                color: subtitleColor,
                                fontSize: 12.5,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                letterSpacing: 0.1,
                              ),
                            ),
                            if (isUnread && showUnreadDot) ...[
                              const SizedBox(width: 8),
                              const _UnreadDot(),
                            ]
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Message
                    Text(
                      message,
                      maxLines: maxMessageLines,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8, height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF005CE7),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ==== AVATAR (image -> initials -> icon fallback) ============================

/// Always shows an avatar when `show` is true.
/// If `image` is null/empty, it renders a fallback (initials or person icon).
class AvatarOrFallback extends StatelessWidget {
  final bool show;
  final String? image;            // asset path or network URL
  final String? labelForInitials; // e.g. requester/tenant name or title

  const AvatarOrFallback({
    super.key,
    required this.show,
    this.image,
    this.labelForInitials,
  });

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    final first = parts.isNotEmpty ? parts.first : '';
    final last  = parts.length > 1 ? parts.last : '';
    final a = first.isNotEmpty ? first[0] : '';
    final b = last.isNotEmpty  ? last[0]  : (parts.length == 1 && first.length > 1 ? first[1] : '');
    return (a + b).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    final hasImage = image != null && image!.trim().isNotEmpty;

    if (hasImage) {
      final isNetwork = image!.startsWith('http://') || image!.startsWith('https://');
      return CircleAvatar(
        radius: 14,
        backgroundColor: Colors.transparent,
        backgroundImage: isNetwork ? NetworkImage(image!) : AssetImage(image!) as ImageProvider,
        onBackgroundImageError: (_, __) {}, // quietly ignore errors
      );
    }

    if (labelForInitials != null && labelForInitials!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: const Color(0xFFE5E7EB),
        child: Text(
          _initials(labelForInitials!),
          style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return const CircleAvatar(
      radius: 14,
      backgroundColor: Color(0xFFE5E7EB),
      child: Icon(Icons.person, size: 16, color: Color(0xFF667085)),
    );
  }
}

// ==== REPAIR CARD ============================================================

class RepairCard extends StatelessWidget {
  // Required
  final String title;
  final String requestId;
  final String reqDate;
  final String? requestType; // (e.g. "Concern Slip", "Job Service")
  final String statusTag;
  final String? priority;

  final String? departmentTag;

  // Admin/staff side extras
  final String? unit;
  

  /// Optional legacy avatar image (applies to all, if you want to show a photo).
  /// If you have per-person photos, pass them through the *_PhotoUrl fields below instead.
  final String? avatarUrl;

  // --- Sources for assignee display (read from details) ----------------------
  final bool? hasInitialAssessment;
  final String? initialAssigneeName;
  final String? initialAssigneeDepartment;
  final String? initialAssigneePhotoUrl;

  final bool? hasCompletionAssessment;
  final String? completionAssigneeName;
  final String? completionAssigneeDepartment;
  final String? completionAssigneePhotoUrl;

  final String? assignedTo;               // generic "Assigned To"
  final String? assignedDepartment;
  final String? assignedPhotoUrl;

  // Actions
  final VoidCallback? onTap;
  final VoidCallback? onChatTap;

  const RepairCard({
    super.key,
    required this.title,
    required this.requestId,
    required this.reqDate,
    required this.statusTag,
    this.requestType,
    this.unit,
    this.priority,
    this.departmentTag,
    this.avatarUrl,
    // assignment sources
    this.hasInitialAssessment,
    this.initialAssigneeName,
    this.initialAssigneeDepartment,
    this.initialAssigneePhotoUrl,
    this.hasCompletionAssessment,
    this.completionAssigneeName,
    this.completionAssigneeDepartment,
    this.completionAssigneePhotoUrl,
    this.assignedTo,
    this.assignedDepartment,
    this.assignedPhotoUrl,
    this.onTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg    = Color(0xFFFFFFFF);
    const border    = Color(0xFFDDDEE0);
    const titleCol  = Color(0xFF101828);
    const sub1Color = Color(0xFF4A5154);
    const sub2Color = Color(0xFF667085);

    // ---- Build assignee DATA (not widgets) so we can compact/collapse cleanly ----
    final assignees = <_AssigneeData>[];

    if ((assignedTo ?? '').trim().isNotEmpty) {
      assignees.add(_AssigneeData(
        name: assignedTo!.trim(),
        department: assignedDepartment?.trim(),
        photoUrl: (assignedPhotoUrl ?? '').trim().isNotEmpty
            ? assignedPhotoUrl!.trim()
            : (avatarUrl ?? ''),
        requestType: requestType?.trim(),
      ));
    }

    if (hasInitialAssessment == true && (initialAssigneeName ?? '').trim().isNotEmpty) {
      assignees.add(_AssigneeData(
        name: initialAssigneeName!.trim(),
        department: initialAssigneeDepartment?.trim(),
        photoUrl: (initialAssigneePhotoUrl ?? '').trim().isNotEmpty
            ? initialAssigneePhotoUrl!.trim()
            : null,
        requestType: requestType?.trim(),
      ));
    }

    if (hasCompletionAssessment == true && (completionAssigneeName ?? '').trim().isNotEmpty) {
      assignees.add(_AssigneeData(
        name: completionAssigneeName!.trim(),
        department: completionAssigneeDepartment?.trim(),
        photoUrl: (completionAssigneePhotoUrl ?? '').trim().isNotEmpty
            ? completionAssigneePhotoUrl!.trim()
            : null,
        requestType: requestType?.trim(),
      ));
    }

    // ---- Left cluster (compact, single-line) ----
    Widget leftCluster;
    if (assignees.isNotEmpty) {
      final extraCount = assignees.length - 1;
      leftCluster = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact assignee line that can shrink its tags
          Flexible(
            child: _AssigneeLine(
              name: assignees.first.name,
              department: assignees.first.department,
              photoUrl: assignees.first.photoUrl,
              requestType: assignees.first.requestType,
              dense: true, // compact sizes for footer
            ),
          ),
          if (extraCount > 0) ...[
            const SizedBox(width: 6),
            _MoreChip(count: extraCount),
          ],
        ],
      );
    } else {
      // Fallback: department + request type, both constrained to avoid overflow
      leftCluster = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((departmentTag! ?? '').trim().isNotEmpty) ...[
            Flexible(child: _EllipsizedTag(child: DepartmentTag(departmentTag!.trim()))),
            const SizedBox(width: 6),
          ],
          if ((requestType ?? '').trim().isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: RequestTypeTag(
                requestType!.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: ShapeDecoration(
            color: cardBg,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: border),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + tags (top row)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: titleCol,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (priority != null && priority!.trim().isNotEmpty)
                          PriorityTag(priority: priority!.trim()),
                        StatusTag(status: statusTag),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Request ID
                Row(
                  children: [
                    const Icon(Icons.tag, size: 14, color: sub1Color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        requestId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: sub1Color,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Unit (optional)
                if (unit != null && unit!.trim().isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 14, color: sub2Color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          unit!.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: sub2Color,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
 
                  // Date
                  if (reqDate != null && reqDate!.trim().isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: sub2Color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          formatDateRequested(reqDate!.trim()),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: sub2Color,
                            fontSize: 13,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),


                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE6E7EA)),
                const SizedBox(height: 12),

                // Footer: assignees (compact) | date | chat — single line, no scroll
                Row(
                  children: [
                    leftCluster, // don’t wrap with Flexible so it sizes naturally
                    const Spacer(), // flexible spacing
                    IconPill(icon: Icons.chat_bubble_outline, onTap: onChatTap),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Assignee line: circle avatar (photo or initials) + (optional) DepartmentTag + (optional) RequestTypeTag
class _AssigneeLine extends StatelessWidget {
  final String name;
  final String? department;
  final String? photoUrl;
  final String? requestType;
  final bool dense;

  const _AssigneeLine({
    super.key,
    required this.name,
    this.department,
    this.photoUrl,
    this.requestType,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarSize = dense ? 34 : 34;
    final double reqMaxWidth = dense ? 120 : 120;

    final widgets = <Widget>[
      _buildAvatar(photoUrl, name, size: avatarSize),
    ];

    if ((department ?? '').trim().isNotEmpty) {
      widgets.add(const SizedBox(width: 6)); // keep dept gap at 6px
      widgets.add(
        _EllipsizedTag(child: DepartmentTag(department!.trim())),
      );
    }

    if ((requestType ?? '').trim().isNotEmpty) {
      widgets.add(const SizedBox(width: 8)); // tighter gap (4px only)
      widgets.add(
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: reqMaxWidth),
          child: RequestTypeTag(
            requestType!.trim(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  // ---- Avatar helpers ----
  static Widget _buildAvatar(String? url, String name, {double size = 34}) {
    final initials = _initials(name);
    if (url == null || url.trim().isEmpty) {
      return _fallbackCircle(initials, size);
    }

    final u = url.trim();
    Widget image;

    if (u.startsWith('http://') || u.startsWith('https://')) {
      // Remote image
      image = Image.network(
        u,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackCircle(initials, size),
      );
    } else if (u.startsWith('assets/')) {
      // Local asset
      image = Image.asset(
        u,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackCircle(initials, size),
      );
    } else {
      // Could extend here to handle File paths (e.g., from ImagePicker)
      return _fallbackCircle(initials, size);
    }

    return ClipOval(child: image);
  }
  static Widget _fallbackCircle(String initials, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36, // scale with avatar
        ),
      ),
    );
  }

  static String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// --- Small helpers -----------------------------------------------------------

class _AssigneeData {
  final String name;
  final String? department;
  final String? photoUrl;
  final String? requestType;
  _AssigneeData({
    required this.name,
    this.department,
    this.photoUrl,
    this.requestType,
  });
}

class _MoreChip extends StatelessWidget {
  final int count;
  const _MoreChip({super.key, required this.count});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: ShapeDecoration(
        color: const Color(0xFFEFF1F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        '+$count',
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF475467),
        ),
      ),
    );
  }
}

/// Clips any tag widget on the right if space is tight (keeps single line).
class _EllipsizedTag extends StatelessWidget {
  final Widget child;
  const _EllipsizedTag({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        child: child,
      ),
    );
  }
}


// ==== MAINTENANCE CARD =======================================================
class MaintenanceCard extends StatelessWidget {
  // Required
  final String title;
  final String requestId;
  final String date;
  final String status; // "Scheduled" | "In Progress" | "Done" | ...

  // Optional
  final String? unit;
  final String? priority;   // "High" | "Medium" | "Low"
  final String? department; // e.g. "Plumbing"

  // Actions
  final VoidCallback? onTap;
  final VoidCallback? onChatTap;

  // Avatar (generic)
  final bool showAvatar;
  final String? avatarUrl;

  // Assessment assignee
  final bool? hasInitialAssessment;
  final String? initialAssigneeName;
  final String? initialAssigneeDepartment;
  final String? initialAssigneePhotoUrl;

  const MaintenanceCard({
    super.key,
    required this.title,
    required this.requestId,
    required this.date,
    required this.status,
    this.unit,
    this.priority,
    this.department,
    this.onTap,
    this.onChatTap,
    this.showAvatar = false,
    this.avatarUrl,
    this.hasInitialAssessment,
    this.initialAssigneeName,
    this.initialAssigneeDepartment,
    this.initialAssigneePhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    const cardBg    = Color(0xFFFFFFFF);
    const border    = Color(0xFFDDDEE0);
    const titleCol  = Color(0xFF101828);
    const sub1Color = Color(0xFF4A5154);
    const sub2Color = Color(0xFF667085);

    final String unitText = (unit == null || unit!.trim().isEmpty) ? '-' : unit!.trim();
    final String priorityText = (priority == null || priority!.trim().isEmpty) ? 'Medium' : priority!.trim();
    final String deptText = (department == null || department!.trim().isEmpty) ? '-' : department!.trim();

    // Assignee cluster (initial assessment vs fallback department)
    Widget assigneeCluster;
    if (hasInitialAssessment == true && (initialAssigneeName ?? '').trim().isNotEmpty) {
      assigneeCluster = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AvatarOrFallback(
            show: true,
            image: initialAssigneePhotoUrl,
            labelForInitials: initialAssigneeName!,
          ),
          const SizedBox(width: 8),
          DepartmentTag(initialAssigneeDepartment ?? deptText),
        ],
      );
    } else {
      assigneeCluster = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAvatar) ...[
            AvatarOrFallback(
              show: showAvatar,
              image: avatarUrl,
              labelForInitials: title,
            ),
            const SizedBox(width: 8),
          ],
          DepartmentTag(deptText),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: ShapeDecoration(
            color: cardBg,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: border),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + tags
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: titleCol,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        PriorityTag(priority: priorityText),
                        StatusTag(status: status),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Request ID
                Row(
                  children: [
                    const Icon(Icons.tag, size: 14, color: sub1Color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        requestId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: sub1Color,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Unit / Location
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 14, color: sub2Color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        unitText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: sub2Color,
                          fontSize: 13,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE6E7EA)),
                const SizedBox(height: 12),

                // Footer: assignee/department | date/chat
                Row(
                  children: [
                    assigneeCluster,
                    const Spacer(),
                    Pill(icon: Icons.calendar_today, label: date, iconSize: 16),
                    const SizedBox(width: 8),
                    IconPill(icon: Icons.chat_bubble_outline, onTap: onChatTap),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




/// Profile Section Cards

/// Soft card section wrapper for groups like Personal Details, Settings, etc.
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? contentPadding;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: contentPadding ?? EdgeInsets.zero,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsOption extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  const SettingsOption({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

