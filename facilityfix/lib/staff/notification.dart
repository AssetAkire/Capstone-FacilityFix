import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/cards.dart';
import 'package:facilityfix/widgets/helper_models.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _selectedIndex = 3;

  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.calendar_month),
    NavItem(icon: Icons.inventory),
  ];

  // Filter: All or Unread
  NotifFilter _filter = NotifFilter.all;

  // Sample data — replace with your backend data
  final List<NotificationItem> _items = [
    NotificationItem(
      title: 'Request Approved',
      message:
          'Your concern slip has been approved. A maintenance staff member has been assigned.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
      isRead: false,
      icon: Icons.check_circle,
      iconBg: const Color(0xFFF4F5FF),
      iconColor: const Color(0xFF005CE7),
    ),
    NotificationItem(
      title: 'Work Scheduled',
      message: 'Your maintenance request is scheduled for Aug 12, 10:00 AM.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 5)),
      isRead: false,
      icon: Icons.event_available,
      iconBg: const Color(0xFFE8F7F1),
      iconColor: const Color(0xFF19B36E),
    ),
    NotificationItem(
      title: 'New Announcement',
      message: 'Water interruption on Aug 7 from 8:00 AM to 5:00 PM.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
      icon: Icons.campaign,
      iconBg: const Color(0xFFFFFAEB),
      iconColor: const Color(0xFFF79009),
    ),
  ];

  Future<void> _onRefresh() async {
    // TODO: Hook to backend refresh
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {});
  }

  void _onTabTapped(int index) {
    final destinations = [
      const HomePage(),
      const WorkOrderPage(),
      const AnnouncementPage(),
      const CalendarPage(),
      const InventoryPage(),
    ];

    if (index != _selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destinations[index]),
      );
    }
  }

  // ===== Grouping & Formatting =====

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isYesterday(DateTime d) {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return d.year == y.year && d.month == y.month && d.day == y.day;
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${time.month}/${time.day}/${time.year}';
  }

  // Build a flat list with section headers inserted
  List<ListEntry> _buildSectioned() {
    final List<NotificationItem> src = _items
        .where((n) => _filter == NotifFilter.all ? true : !n.isRead)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final entries = <ListEntry>[];

    // Group
    bool addedToday = false;
    bool addedYesterday = false;
    bool addedEarlier = false;

    for (final n in src) {
      if (_isToday(n.timestamp) && !addedToday) {
        entries.add(ListHeader('Today'));
        addedToday = true;
      } else if (_isYesterday(n.timestamp) && !addedYesterday) {
        entries.add(ListHeader('Yesterday'));
        addedYesterday = true;
      } else if (!(_isToday(n.timestamp) || _isYesterday(n.timestamp)) && !addedEarlier) {
        entries.add(ListHeader('Earlier'));
        addedEarlier = true;
      }
      entries.add(ListItem(n));
    }

    if (entries.isEmpty) {
      entries.add(ListHeader(_filter == NotifFilter.unread ? 'No unread' : 'No notifications'));
    }

    return entries;
  }

  void _markAllAsRead() {
    setState(() {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    });
  }

  bool get _hasUnread => _items.any((n) => !n.isRead);

  Widget _leadingIcon(NotificationItem n) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: n.iconBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(n.icon, color: n.iconColor, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildSectioned();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Notifications',
        leading: const Row(
          children: [
            BackButton(),
            SizedBox(width: 8),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _hasUnread ? _markAllAsRead : null,
            style: TextButton.styleFrom(
              foregroundColor: _hasUnread ? const Color(0xFF005CE7) : const Color(0xFF98A2B3),
            ),
            icon: const Icon(Icons.done_all, size: 18),
            label: const Text('Mark all read'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  SegmentChip(
                    label: 'All',
                    selected: _filter == NotifFilter.all,
                    onSelected: () => setState(() => _filter = NotifFilter.all),
                  ),
                  const SizedBox(width: 8),
                  SegmentChip(
                    label: 'Unread',
                    selected: _filter == NotifFilter.unread,
                    onSelected: () => setState(() => _filter = NotifFilter.unread),
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    if (entry is ListHeader) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text(
                          entry.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF667085),
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    }

                    final item = (entry as ListItem).data;

                    return Dismissible(
                      key: ValueKey(item.title + item.timestamp.toIso8601String()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECEC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete_outline, color: Color(0xFFE84545)),
                      ),
                      onDismissed: (_) {
                        final removed = item; // keep a reference

                        // Defer removal to avoid removing a hovered widget in the same frame.
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          setState(() => _items.remove(removed));
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notification dismissed')),
                        );
                      },
                      child: NotificationMessageCard(
                        title: item.title,
                        message: item.message,
                        timeLabel: _timeAgo(item.timestamp),
                        isUnread: !item.isRead,
                        leading: _leadingIcon(item),
                        // You can also pass modern props if you used the upgraded card:
                        // badge: 'System',
                        onTap: () {
                          // Mark read
                          final idx = _items.indexOf(item);
                          if (idx != -1 && !_items[idx].isRead) {
                            setState(() => _items[idx] = _items[idx].copyWith(isRead: true));
                          }

                          // Navigate (demo logic)
                          if (item.title == 'New Announcement') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AnnouncementPage()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WorkOrderPage()),
                            );
                          }
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount: entries.length,
                ),
              ),
            ),
          ],
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
