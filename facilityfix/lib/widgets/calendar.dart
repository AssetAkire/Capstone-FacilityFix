import 'package:facilityfix/admin/chat.dart';
import 'package:facilityfix/widgets/cards.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:facilityfix/widgets/helper_models.dart';

class CalendarPane extends StatefulWidget {
  final DateTime month;
  final Map<DateTime, List<WorkOrder>> tasksByDate;
  final DateTime? initialSelected;

  final void Function(DateTime day)? onDaySelected;
  final void Function(WorkOrder task)? onTaskTap;
  final void Function(WorkOrder task)? onTaskChatTap;
  final void Function(DateTime newMonth)? onMonthChanged;

  const CalendarPane({
    super.key,
    required this.month,
    required this.tasksByDate,
    this.initialSelected,
    this.onDaySelected,
    this.onTaskTap,
    this.onTaskChatTap,
    this.onMonthChanged,
  });

  @override
  State<CalendarPane> createState() => _CalendarPaneState();
}

class _CalendarPaneState extends State<CalendarPane> {
  late DateTime _viewMonth;
  late DateTime _firstDayOfMonth;
  late DateTime _lastDayOfMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime(widget.month.year, widget.month.month);
    _recomputeMonthBounds(_viewMonth);

    final today = DateTime.now();
    final inSameMonth = today.year == _viewMonth.year && today.month == _viewMonth.month;
    _selected = _normalize(widget.initialSelected ?? (inSameMonth ? today : _firstDayOfMonth));
  }

  @override
  void didUpdateWidget(covariant CalendarPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month.year != widget.month.year ||
        oldWidget.month.month != widget.month.month) {
      _viewMonth = DateTime(widget.month.year, widget.month.month);
      _recomputeMonthBounds(_viewMonth);

      final today = DateTime.now();
      final inSameMonth = today.year == _viewMonth.year && today.month == _viewMonth.month;
      _selected = _normalize(inSameMonth ? today : _firstDayOfMonth);
    }
  }

  void _recomputeMonthBounds(DateTime month) {
    _firstDayOfMonth = DateTime(month.year, month.month, 1);
    _lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
  }

  void _gotoPrevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
      _recomputeMonthBounds(_viewMonth);
      final today = DateTime.now();
      final inSameMonth = today.year == _viewMonth.year && today.month == _viewMonth.month;
      _selected = _normalize(inSameMonth ? today : _firstDayOfMonth);
    });
    widget.onMonthChanged?.call(_viewMonth);
    widget.onDaySelected?.call(_selected);
  }

  void _gotoNextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
      _recomputeMonthBounds(_viewMonth);
      final today = DateTime.now();
      final inSameMonth = today.year == _viewMonth.year && today.month == _viewMonth.month;
      _selected = _normalize(inSameMonth ? today : _firstDayOfMonth);
    });
    widget.onMonthChanged?.call(_viewMonth);
    widget.onDaySelected?.call(_selected);
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  String _weekday(DateTime d) => DateFormat('EEE').format(d).toUpperCase();
  String _dayNum(DateTime d) => DateFormat('d').format(d);

  bool _hasTasks(DateTime d) {
    final k = _normalize(d);
    return (widget.tasksByDate[k]?.isNotEmpty ?? false);
  }

  List<WorkOrder> _tasksFor(DateTime d) =>
      widget.tasksByDate[_normalize(d)] ?? const <WorkOrder>[];

  // Fix: CS/JS → RepairCard, MT → MaintenanceCard
  bool _isRepair(WorkOrder t) {
    final id = (t.requestId).toUpperCase();
    final rt = (t.requestType ?? '').toLowerCase().trim();

    final isMaintenance = id.startsWith('MT') || rt.contains('maintenance');
    if (isMaintenance) return false;

    if (id.startsWith('CS') || id.startsWith('JS')) return true;
    if (rt == 'concern slip' || rt == 'job service') return true;

    return !id.startsWith('MT');
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_firstDayOfMonth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0x1A000000)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left),
                onPressed: _gotoPrevMonth,
                tooltip: 'Previous month',
              ),
              Expanded(
                child: Center(
                  child: Text(
                    monthLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right),
                onPressed: _gotoNextMonth,
                tooltip: 'Next month',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date strip
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _lastDayOfMonth.day,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final day = DateTime(_firstDayOfMonth.year, _firstDayOfMonth.month, i + 1);
                final isSelected = _normalize(day) == _selected;
                final hasTasks = _hasTasks(day);

                final now = DateTime.now();
                final isToday = now.year == day.year && now.month == day.month && now.day == day.day;

                return _DayTile(
                  weekday: _weekday(day),
                  day: _dayNum(day),
                  selected: isSelected,
                  hasTasks: hasTasks,
                  isToday: isToday,
                  onTap: () {
                    setState(() => _selected = _normalize(day));
                    widget.onDaySelected?.call(_selected);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Task list
          Expanded(
            child: SingleChildScrollView(
              child: _TaskList(
                tasks: _tasksFor(_selected),
                onTap: widget.onTaskTap,
                onChatTap: widget.onTaskChatTap,
                isRepairPredicate: _isRepair,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  final String weekday;
  final String day;
  final bool selected;
  final bool hasTasks;
  final bool isToday;
  final VoidCallback onTap;

  const _DayTile({
    required this.weekday,
    required this.day,
    required this.selected,
    required this.hasTasks,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF005CE7) : (isToday ? const Color(0xFFEFF4FF) : Colors.white);
    final fg = selected ? Colors.white : Colors.black;
    final border = selected ? Colors.transparent : const Color(0xFFE5E7EB);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weekday, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
            const SizedBox(height: 4),
            Text(day, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: fg)),
            const SizedBox(height: 6),
            if (hasTasks)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected ? Colors.white : const Color(0xFF005CE7),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final List<WorkOrder> tasks;
  final void Function(WorkOrder task)? onTap;
  final void Function(WorkOrder task)? onChatTap;

  final bool Function(WorkOrder t)? isRepairPredicate;

  const _TaskList({
    required this.tasks,
    this.onTap,
    this.onChatTap,
    this.isRepairPredicate,
  });

  bool _isRepairDefault(WorkOrder t) {
    final id = t.requestId.toUpperCase();
    final rt = (t.requestType ?? '').toLowerCase().trim();
    final isMaintenance = id.startsWith('MT') || rt.contains('maintenance');
    if (isMaintenance) return false;
    if (id.startsWith('CS') || id.startsWith('JS')) return true;
    if (rt == 'concern slip' || rt == 'job service') return true;
    return !id.startsWith('MT');
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No tasks for this day.',
            style: TextStyle(color: Color(0xFF667085)),
          ),
        ),
      );
    }

    final isRepairFn = isRepairPredicate ?? _isRepairDefault;

    return Column(
      children: tasks.map((t) {
        final isRepair = isRepairFn(t);

        if (isRepair) {
          // Tenant / Repair card
          return Padding(
            key: ValueKey('repair-${t.requestId}'),
            padding: const EdgeInsets.only(bottom: 12),
            child: RepairCard(
              title: t.title,
              requestId: t.requestId,
              reqDate: t.date,
              statusTag: t.status,
              unit: t.unit,
              priority: t.priority,
              departmentTag: t.department,
              requestType: t.requestType,

              // Current assignment
              assignedTo: t.assignedTo,
              assignedDepartment: t.assignedDepartment,
              assignedPhotoUrl: t.assignedPhotoUrl,

              // Initial Assessment
              hasInitialAssessment: t.hasInitialAssessment,
              initialAssigneeName: t.initialAssigneeName,
              initialAssigneeDepartment: t.initialAssigneeDepartment,
              initialAssigneePhotoUrl: t.initialAssigneePhotoUrl,

              // Completion Assessment
              hasCompletionAssessment: t.hasCompletionAssessment,
              completionAssigneeName: t.completionAssigneeName,
              completionAssigneeDepartment: t.completionAssigneeDepartment,
              completionAssigneePhotoUrl: t.completionAssigneePhotoUrl,

              // Legacy fallback photo
              avatarUrl: t.avatarUrl,

              onTap: onTap == null ? null : () => onTap!(t),
              onChatTap: onChatTap == null ? null : () => onChatTap!(t),
            ),
          );
        }

        // Admin / Maintenance card
        return Padding(
          key: ValueKey('maint-${t.requestId}'),
          padding: const EdgeInsets.only(bottom: 12),
          child: MaintenanceCard(
            title: t.title,
            requestId: t.requestId,
            unit: t.unit ?? '-',
            date: t.date,
            status: t.status,
            priority: t.priority ?? 'Medium',
            department: t.department,

            // Assignee (initial) so avatar shows
            hasInitialAssessment: t.hasInitialAssessment,
            initialAssigneeName: t.initialAssigneeName,
            initialAssigneeDepartment: t.initialAssigneeDepartment,
            initialAssigneePhotoUrl: t.initialAssigneePhotoUrl,

            onTap: onTap == null ? null : () => onTap!(t),    
            // onChatTap: onChatTap == null ? null : () => onChatTap!(t),
            onChatTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
