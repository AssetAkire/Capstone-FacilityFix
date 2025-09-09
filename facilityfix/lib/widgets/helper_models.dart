import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.announcement_outlined,
              size: 64,
              color: Color(0xFF9AA0A6),
            ),
            SizedBox(height: 12),
            Text(
              'Nothing to see here yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text(
              'No announcements match your current filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF697076)),
            ),
          ],
        ),
      ),
    );
  }
}

enum AnnStatusFilter { all, unread, read, recent }

class Announcement {
  final String title;
  final String classification; // e.g., 'utility interruption'
  final String details;
  final DateTime postedAt;
  final bool isRead;

  Announcement({
    required this.title,
    required this.classification,
    required this.details,
    required this.postedAt,
    required this.isRead,
  });

  Announcement copyWith({
    String? title,
    String? classification,
    String? details,
    DateTime? postedAt,
    bool? isRead,
  }) {
    return Announcement(
      title: title ?? this.title,
      classification: classification ?? this.classification,
      details: details ?? this.details,
      postedAt: postedAt ?? this.postedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class UnreadDot extends StatelessWidget {
  const UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF005CE7),
        shape: BoxShape.circle,
      ),
    );
  }
}

class SegmentChip extends StatelessWidget {
  const SegmentChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color:
            selected
                ? const Color(0xFF005CE7).withOpacity(0.10)
                : const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? const Color(0xFF005CE7) : const Color(0xFFE4E7EC),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onSelected,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:
                  selected ? const Color(0xFF005CE7) : const Color(0xFF475467),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Repair Card design

// Avatar
class Avatar extends StatelessWidget {
  final String? avatarUrl;
  const Avatar({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFD9D9D9);

    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: bg,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }

    return const CircleAvatar(
      radius: 14,
      backgroundColor: bg,
      child: Icon(Icons.person, size: 14, color: Colors.white),
    );
  }
}

/// Text pill with an icon (for date)
class Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;

  const Pill({required this.icon, required this.label, this.iconSize = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: const Color(0xFF101828)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon-only small pill (for chat)
class IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const IconPill({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 40,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(enabled ? 1 : 0.7),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? const Color(0xFF101828) : const Color(0xFF98A2B3),
        ),
      ),
    );
  }
}

// ===== Work order Models View Details Repair ============================================================

/// Represents a Work Order / Concern Slip / Job Service item
class WorkOrder {
  final String title;
  final String requestId;
  final String date;
  final String status;
  final String? unit;
  final String? priority;
  final String? department;
  final String? requestType;

  // New fields to support RepairCard
  final String? avatarUrl;

  final bool? hasInitialAssessment;
  final String? initialAssigneeName;
  final String? initialAssigneeDepartment;
  final String? initialAssigneePhotoUrl;

  final bool? hasCompletionAssessment;
  final String? completionAssigneeName;
  final String? completionAssigneeDepartment;
  final String? completionAssigneePhotoUrl;

  final String? assignedTo;
  final String? assignedDepartment;
  final String? assignedPhotoUrl;

  WorkOrder({
    required this.title,
    required this.requestId,
    required this.date,
    required this.status,
    this.unit,
    this.priority,
    this.department,
    this.requestType,
    this.avatarUrl,
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
  });
}


// Date
class UiDateParser {
  static const Map<String, int> monthIndex = {
    'jan': 1,
    'january': 1,
    'feb': 2,
    'february': 2,
    'mar': 3,
    'march': 3,
    'apr': 4,
    'april': 4,
    'may': 5,
    'jun': 6,
    'june': 6,
    'jul': 7,
    'july': 7,
    'aug': 8,
    'august': 8,
    'sep': 9,
    'sept': 9,
    'september': 9,
    'oct': 10,
    'october': 10,
    'nov': 11,
    'november': 11,
    'dec': 12,
    'december': 12,
  };

  /// Parses "Sep 28", "Sept 28", "Aug 3", and "Sep 28, 2025".
  /// If year is omitted, [defaultYear] (or current year) is used.
  /// If parsing fails, returns a very old date so it sorts to the bottom
  /// when using latest-first ordering.
  static DateTime parse(String input, {int? defaultYear}) {
    final year = defaultYear ?? DateTime.now().year;

    // Quick path: ISO-like strings (e.g., 2025-09-28)
    final iso = DateTime.tryParse(input.trim());
    if (iso != null) return iso;

    final re = RegExp(r'^\s*([A-Za-z]+)\s+(\d{1,2})(?:,\s*(\d{4}))?\s*$');
    final match = re.firstMatch(input);
    if (match == null) {
      // Far past so unparsable values sink in latest-first sorts
      return DateTime(1900, 1, 1);
    }

    final monStr = match.group(1)!.toLowerCase();
    final dayStr = match.group(2)!;
    final yrStr = match.group(3);

    final mon = monthIndex[monStr] ?? 12;
    final day = int.tryParse(dayStr) ?? 1;
    final yr = yrStr == null ? year : (int.tryParse(yrStr) ?? year);
    return DateTime(yr, mon, day);
  }

  /// Comparator for ascending (oldest → latest)
  static int compareAsc(String a, String b, {int? defaultYear}) => parse(
    a,
    defaultYear: defaultYear,
  ).compareTo(parse(b, defaultYear: defaultYear));

  /// Comparator for descending (latest → oldest)
  static int compareDesc(String a, String b, {int? defaultYear}) => parse(
    b,
    defaultYear: defaultYear,
  ).compareTo(parse(a, defaultYear: defaultYear));

  /// Convenience sorter for any list where you can map an item to the date string.
  static void sortLatestFirst<T>(
    List<T> list,
    String Function(T) dateSelector, {
    int? defaultYear,
  }) {
    list.sort(
      (a, b) => compareDesc(
        dateSelector(a),
        dateSelector(b),
        defaultYear: defaultYear,
      ),
    );
  }
}

// Notification
// ===== Models / helpers =====

enum NotifFilter { all, unread }

class NotificationItem {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  NotificationItem copyWith({
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    IconData? icon,
    Color? iconBg,
    Color? iconColor,
  }) {
    return NotificationItem(
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      iconBg: iconBg ?? this.iconBg,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}

// List entry union for headers & items
abstract class ListEntry {}

class ListHeader extends ListEntry {
  final String label;
  ListHeader(this.label);
}

class ListItem extends ListEntry {
  final NotificationItem data;
  ListItem(this.data);
}

/// ====================== MODELS / HELPERS ON HOLD ======================= ///

/// Compact banner shown at the top of details if request is On Hold.
class OnHoldBanner extends StatelessWidget {
  final HoldResult hold;
  const OnHoldBanner({required this.hold});

  @override
  Widget build(BuildContext context) {
    final untilText =
        hold.resumeAt != null
            ? ' — until ${formatDateTime(hold.resumeAt!)}'
            : '';
    final noteText =
        (hold.note ?? '').trim().isEmpty ? '' : '\nNote: ${hold.note!.trim()}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1C78C)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.pause_circle_filled, color: Color(0xFF9A6700)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'On Hold: ${hold.reason}$untilText$noteText',
              style: const TextStyle(
                color: Color(0xFF9A6700),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// =============================================
/// BOTTOM SHEET: PUT REQUEST ON HOLD (refined UI)
/// =============================================
class HoldBottomSheet extends StatefulWidget {
  final HoldResult? initial;
  const HoldBottomSheet({super.key, this.initial});

  @override
  State<HoldBottomSheet> createState() => _HoldBottomSheetState();
}

class _HoldBottomSheetState extends State<HoldBottomSheet> {
  final TextEditingController _note = TextEditingController();

  // Reasons + optional icons
  static const _reasons = <String>[
    'Waiting for materials',
    'Tenant unavailable',
    'Rescheduled',
    'Awaiting approval',
    'Weather constraints',
    'Other',
  ];

  static const Map<String, IconData> _reasonIcons = {
    'Waiting for materials': Icons.inventory_2_outlined,
    'Tenant unavailable': Icons.sentiment_dissatisfied_outlined,
    'Rescheduled': Icons.event_repeat,
    'Awaiting approval': Icons.verified_outlined,
    'Weather constraints': Icons.thunderstorm_outlined,
    'Other': Icons.more_horiz,
  };

  late String _selectedReason;
  DateTime? _resumeAt;

  @override
  void initState() {
    super.initState();
    _selectedReason = widget.initial?.reason ?? _reasons.first;
    _resumeAt = widget.initial?.resumeAt;
    _note.text = widget.initial?.note ?? '';
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final base = _resumeAt ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      builder: (ctx, child) => _ThemedPicker(child: child),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
      builder: (ctx, child) => _ThemedPicker(child: child),
    );

    setState(() {
      _resumeAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? base.hour,
        pickedTime?.minute ?? base.minute,
      );
    });
  }

  void _clearDateTime() {
    setState(() => _resumeAt = null);
  }

  void _confirm() {
    Navigator.pop(
      context,
      HoldResult(
        reason: _selectedReason,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        resumeAt: _resumeAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grabber + Title
              const SizedBox(height: 8),
              _Grabber(),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _SheetTitle('Put Request On Hold'),
              ),
              const SizedBox(height: 8),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('Reason'),
                      const SizedBox(height: 8),
                      _ReasonChips(
                        reasons: _reasons,
                        icons: _reasonIcons,
                        selected: _selectedReason,
                        onChanged: (r) => setState(() => _selectedReason = r),
                      ),
                      const SizedBox(height: 16),

                      const _SectionLabel('Resume date & time'),
                      const SizedBox(height: 8),
                      _ResumePickerRow(
                        valueText: _resumeAt == null
                            ? 'Set date & time'
                            : formatDateTime(_resumeAt!),
                        onPick: _pickDateTime,
                        onClear: _resumeAt == null ? null : _clearDateTime,
                      ),
                      const SizedBox(height: 16),

                      const _SectionLabel('Note (optional)'),
                      const SizedBox(height: 8),
                      _NoteField(controller: _note),
                    ],
                  ),
                ),
              ),

              // Sticky action bar
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: cs.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.pause_circle_outline),
                        label: const Text('Confirm Hold'),
                        onPressed: _confirm,
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

/// Helper: themed wrapper for date/time pickers
class _ThemedPicker extends StatelessWidget {
  final Widget? child;
  const _ThemedPicker({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: theme.colorScheme.primary,
          onPrimary: theme.colorScheme.onPrimary,
          surface: Colors.white,
          onSurface: theme.colorScheme.onSurface,
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

/// Grabber
class _Grabber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

/// Title
class _SheetTitle extends StatelessWidget {
  final String text;
  const _SheetTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.1,
      ),
    );
  }
}

/// Section label
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF475467),
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.15,
      ),
    );
  }
}

/// Reason chips (pill style)
class _ReasonChips extends StatelessWidget {
  final List<String> reasons;
  final Map<String, IconData> icons;
  final String selected;
  final ValueChanged<String> onChanged;

  const _ReasonChips({
    required this.reasons,
    required this.icons,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: reasons.map((r) {
        final isSelected = r == selected;
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icons[r] ?? Icons.more_horiz,
                size: 16,
                color: isSelected ? cs.onPrimary : cs.primary,
              ),
              const SizedBox(width: 6),
              Text(r),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(r),
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? cs.primary : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          showCheckmark: false,
          selectedColor: cs.primary,
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? cs.onPrimary : const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}

/// Resume date/time row with Set & Clear actions
class _ResumePickerRow extends StatelessWidget {
  final String valueText;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _ResumePickerRow({
    required this.valueText,
    required this.onPick,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasValue = onClear != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 20, color: Color(0xFF475467)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              valueText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onPick,
            style: TextButton.styleFrom(
              foregroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.edit_calendar_outlined, size: 18),
            label: const Text('Set'),
          ),
          if (hasValue) ...[
            const SizedBox(width: 4),
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9CA3AF),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Clear'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Note field with soft outline + counter
class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      maxLength: 200,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Add extra details…',
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.4),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }
}

/* ================== SHEET HELPER ================== */

Future<HoldResult?> showHoldSheet(BuildContext context, {HoldResult? initial}) {
  return showModalBottomSheet<HoldResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent, // let our Material shape render
    builder: (ctx) => HoldBottomSheet(initial: initial),
  );
}

/// ================== YOUR EXISTING TYPES ==================
/// Keep using your own HoldResult & formatDateTime implementations.
class HoldResult {
  final String reason;
  final String? note;
  final DateTime? resumeAt;
  HoldResult({required this.reason, this.note, this.resumeAt});
}

// Expects you already have this util in your project.
String formatDateTime(DateTime dt) {
  // Implement as you already do elsewhere
  // Example:
  // return DateFormat('MMM d, yyyy • h:mm a').format(dt);
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}


/* ================== WORK ORDER DETAILS ADMIN SIDE ================== */
// =========================== Assign Staff Bottom Sheet =======================
// Drop-in pretty UI: search + “Only available” filter, clear availability
// badges, subtle elevation, nicer list items, and a confident CTA.

class AssignResult {
  final String staffName;
  final String? note;
  const AssignResult({required this.staffName, this.note});
}

/// Demo model of availability. Replace with your real data.
class BusySlot {
  final String reason;
  const BusySlot(this.reason);
}

class AssignStaffBottomSheet extends StatefulWidget {
  /// Optional: pass your own data (falls back to demo lists if null).
  final List<String>? staff;
  final Map<String, BusySlot?>? busyByStaff;

  const AssignStaffBottomSheet({super.key, this.staff, this.busyByStaff});

  @override
  State<AssignStaffBottomSheet> createState() => _AssignStaffBottomSheetState();
}

class _AssignStaffBottomSheetState extends State<AssignStaffBottomSheet> {
  // Demo staff data (replace with your live data)
  late final List<String> _staff =
      widget.staff ??
      const <String>[
        'Juan Dela Cruz (Plumber)',
        'Maria Santos (Electrician)',
        'Jose Reyes (Carpenter)',
        'Ana Lim (HVAC)',
      ];

  // Mark some staff busy (replace with your live data)
  late final Map<String, BusySlot?> _busyByStaff =
      widget.busyByStaff ??
      <String, BusySlot?>{
        'Juan Dela Cruz (Plumber)': const BusySlot('On another job'),
        'Maria Santos (Electrician)': null,
        'Jose Reyes (Carpenter)': const BusySlot('Day off'),
        'Ana Lim (HVAC)': null,
      };

  String? _selectedStaff;
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  bool _onlyAvailable = true;

  @override
  void initState() {
    super.initState();
    _selectedStaff = _autoSelectFirstAvailable();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String? _autoSelectFirstAvailable() {
    for (final s in _staff) {
      if (_busyByStaff[s] == null) return s;
    }
    return null;
  }

  List<String> get _filteredStaff {
    final q = _searchCtrl.text.trim().toLowerCase();
    var list = _staff.where((s) => s.toLowerCase().contains(q)).toList();
    if (_onlyAvailable) {
      list = list.where((s) => _busyByStaff[s] == null).toList();
    }
    return list;
  }

  Color _availabilityColor(bool available) =>
      available ? const Color(0xFF16A34A) : const Color(0xFFB91C1C);

  Color _availabilityBg(bool available) =>
      available ? const Color(0xFFEFFCF2) : const Color(0xFFFFF1F2);

  IconData _availabilityIcon(bool available) =>
      available ? Icons.check_circle : Icons.block;

  String _initialsOf(String full) {
    // Quick initials: take first char of first two tokens
    final parts = full.split(' ');
    final chars = <String>[];
    for (final p in parts) {
      if (p.isEmpty) continue;
      final c = p.characters.first;
      if (RegExp(r'[A-Za-z]').hasMatch(c)) chars.add(c.toUpperCase());
      if (chars.length == 2) break;
    }
    return chars.isEmpty ? '•' : chars.join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = _filteredStaff;

    // keep selection consistent with filtered list
    if (_selectedStaff != null && !list.contains(_selectedStaff)) {
      _selectedStaff = list.isNotEmpty ? list.first : null;
    }

  return Container(
    decoration: const BoxDecoration(
      color: Colors.white, 
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20), 
      ),
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Grabber
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            'Assign to Staff',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 10),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Search + filter row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search staff by name or role…',
                          prefixIcon: const Icon(Icons.search),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: _onlyAvailable,
                            onChanged:
                                (v) => setState(() => _onlyAvailable = v),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Only available',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Staff card list
                if (list.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      color: const Color(0xFFFCFCFD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'No staff match your filters.\nTry a different search',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final name = list[i];
                        final busy = _busyByStaff[name];
                        final available = busy == null;
                        final selected = _selectedStaff == name;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  selected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFE5E7EB),
                              width: selected ? 2 : 1,
                            ),
                            boxShadow: [
                              if (selected)
                                BoxShadow(
                                  color: const Color(
                                    0xFF2563EB,
                                  ).withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              if (!selected)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap:
                                available
                                    ? () =>
                                        setState(() => _selectedStaff = name)
                                    : null,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Avatar with initials
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        available
                                            ? const Color(0xFFEFF6FF)
                                            : const Color(0xFFFFF7ED),
                                    child: Text(
                                      _initialsOf(name),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color:
                                            available
                                                ? const Color(0xFF1D4ED8)
                                                : const Color(0xFF9A3412),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Name + badge
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _availabilityBg(available),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                            border: Border.all(
                                              color: _availabilityColor(
                                                available,
                                              ).withOpacity(0.28),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _availabilityIcon(available),
                                                size: 16,
                                                color: _availabilityColor(
                                                  available,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                available
                                                    ? 'Available'
                                                    : 'Busy — ${busy.reason}',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: _availabilityColor(
                                                    available,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Select radio
                                  const SizedBox(width: 10),
                                  Radio<String>(
                                    value: name,
                                    groupValue: _selectedStaff,
                                    onChanged:
                                        available
                                            ? (v) => setState(
                                              () => _selectedStaff = v,
                                            )
                                            : null,
                                    activeColor: const Color(0xFF005CE7),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 14),

                // Optional note
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Note (optional)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: Color(0xFF374151), // subtle gray tone
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Add any instructions or reminders…',
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Sticky Actions
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
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _selectedStaff == null
                            ? null
                            : () {
                              Navigator.pop(
                                context,
                                AssignResult(
                                  staffName: _selectedStaff!,
                                  note:
                                      _noteCtrl.text.trim().isEmpty
                                          ? null
                                          : _noteCtrl.text.trim(),
                                ),
                              );
                            },
                    icon: const Icon(Icons.person_add_alt),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Assign',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(48),
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: const Color(0xFF16A34A).withOpacity(0.28),
                      disabledBackgroundColor: const Color(0xFF86EFAC),
                      disabledForegroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      )
    );
  }
}

// ============================ Reject Bottom Sheet ============================
class RejectResult {
  final String reason;
  final String? note;
  const RejectResult({required this.reason, this.note});
}

class RejectBottomSheet extends StatefulWidget {
  const RejectBottomSheet({super.key});

  @override
  State<RejectBottomSheet> createState() => _RejectBottomSheetState();
}

class _RejectBottomSheetState extends State<RejectBottomSheet> {
  final _reasons = const <String>[
    'Insufficient details',
    'Out of scope',
    'Duplicate request',
    'Schedule conflict',
    'Other',
  ];

  String _selected = 'Insufficient details';
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Color get _danger => const Color(0xFFDC2626);
  Color get _dangerSoft => const Color(0xFFFFE4E6);
  Color get _ink => const Color(0xFF111827);
  Color get _muted => const Color(0xFF6B7280);
  Color get _stroke => const Color(0xFFD0D5DD);
  Color get _panel => Colors.white;

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
            color: _panel,
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

                // Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      'Reject Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Info banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _dangerSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _danger.withOpacity(.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: _danger),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This action notifies the tenant and updates the work order status.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: _danger.withOpacity(.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section label
                        Text(
                          'Reason',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _muted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Reason chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _reasons.map((r) {
                                final selected = r == _selected;
                                return ChoiceChip(
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Text(
                                      r,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: selected ? _danger : _ink,
                                      ),
                                    ),
                                  ),
                                  selected: selected,
                                  onSelected:
                                      (_) => setState(() => _selected = r),
                                  backgroundColor: const Color(0xFFF8FAFC),
                                  selectedColor: _dangerSoft,
                                  shape: StadiumBorder(
                                    side: BorderSide(
                                      color: selected ? _danger : _stroke,
                                    ),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 2,
                                  ),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 14),

                        // Note field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Note (optional)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: Color(0xFF374151), // subtle gray tone
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _noteCtrl,
                              maxLines: 3,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: 'Add any instructions or reminders…',
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                isDense: true,
                                contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions Cancel and Reject Button
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
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              RejectResult(
                                reason: _selected,
                                note:
                                    _noteCtrl.text.trim().isEmpty
                                        ? null
                                        : _noteCtrl.text.trim(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_forever_outlined),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text(
                              'Reject',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size.fromHeight(48),
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: const Color(
                              0xFFDC2626,
                            ).withOpacity(0.28),
                            disabledBackgroundColor: const Color(0xFFFCA5A5),
                            disabledForegroundColor: Colors.white,
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

/// ===== Home Helpers  ====================================
class SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onActionTap; 

  const SectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF005CE7),
            ),
          ),
        ),
      ],
    );
  }
}
