import 'dart:async';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/notification.dart';
import 'package:facilityfix/admin/view_details/announcement_details.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/buttons.dart'; // AddButton lives here
import 'package:facilityfix/widgets/cards.dart'; // AnnouncementCard, EmptyState
import 'package:facilityfix/widgets/app&nav_bar.dart'; // CustomAppBar, NavBar, NavItem
import 'package:facilityfix/widgets/helper_models.dart'; // Announcement model
import 'package:flutter/material.dart';

// Create form
import 'package:facilityfix/admin/forms/announcement.dart'; // AnnouncementForm

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  int _selectedIndex = 2;

  // ---------------- Bottom Nav ----------------
  final List<NavItem> _navItems = const [
    NavItem(icon: Icons.home),
    NavItem(icon: Icons.work),
    NavItem(icon: Icons.announcement_rounded),
    NavItem(icon: Icons.calendar_month),
    NavItem(icon: Icons.inventory),
  ];

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
      setState(() => _selectedIndex = index);
    }
  }

  // ===== Search, classification & read-status filters =====
  final TextEditingController _searchController = TextEditingController();

  // Classification (announcement categories)
  String _selectedClassification = "All";
  final List<String> _classifications = const [
    'All',
    'Utility Interruption',
    'Power Outage',
    'Pest Control',
    'General Maintenance',
  ];

  // Status filter: string shown in UI + enum used in logic (kept in sync)
  String _selectedStatus = 'All';
  final List<String> _statuses = const ['All', 'Unread', 'Read', 'Recent'];
  AnnStatusFilter _statusFilter = AnnStatusFilter.all;

  AnnStatusFilter _toFilter(String s) {
    switch (s.toLowerCase()) {
      case 'unread':
        return AnnStatusFilter.unread;
      case 'read':
        return AnnStatusFilter.read;
      case 'recent':
        return AnnStatusFilter.recent;
      default:
        return AnnStatusFilter.all;
    }
  }

  // ===== Demo data (replace with backend) =====
  final List<Announcement> _all = [
    Announcement(
      title: 'Utility Interruption',
      classification: 'utility interruption',
      details: 'Temporary shutdown in pipelines for maintenance cleaning.',
      postedAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
    ),
    Announcement(
      title: 'Power Outage',
      classification: 'power outage',
      details: 'Scheduled power interruption due to transformer maintenance.',
      postedAt: DateTime.now().subtract(const Duration(hours: 27)),
      isRead: true,
    ),
    Announcement(
      title: 'General Maintenance',
      classification: 'general maintenance',
      details: 'Common area repainting and minor repairs this weekend.',
      postedAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
    ),
    Announcement(
      title: 'Pest Control',
      classification: 'pest control',
      details: 'Building-wide pest control on Saturday, secure food items.',
      postedAt: DateTime.now().subtract(const Duration(days: 11)),
      isRead: true,
    ),
  ];

  // ===== Debounce for search =====
  Timer? _debounce;
  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => _onSearchChanged(_searchController.text));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ===== Filtering logic =====
  bool _isRecent(DateTime dt) => DateTime.now().difference(dt).inDays <= 7;

  bool _matchesClassification(String classification) {
    if (_selectedClassification == 'All') return true;
    return classification.toLowerCase() == _selectedClassification.toLowerCase();
  }

  bool _matchesSearch(String haystack) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return haystack.toLowerCase().contains(q);
  }

  bool _matchesStatus(Announcement a) {
    switch (_statusFilter) {
      case AnnStatusFilter.all:
        return true;
      case AnnStatusFilter.unread:
        return !a.isRead;
      case AnnStatusFilter.read:
        return a.isRead;
      case AnnStatusFilter.recent:
        return _isRecent(a.postedAt);
    }
  }

  List<Announcement> get _filteredAnnouncements {
    return _all.where((a) {
      final classMatch = _matchesClassification(a.classification);
      final searchMatch = _matchesSearch("${a.title} ${a.details} ${a.classification}");
      final statusMatch = _matchesStatus(a);
      return classMatch && searchMatch && statusMatch;
    }).toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));
  }

  Future<void> _refresh() async {
    // TODO: replace with backend fetch
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {});
  }

  String headerTitle() {
    switch (_statusFilter) {
      case AnnStatusFilter.all:
        return 'All Announcements';
      case AnnStatusFilter.unread:
        return 'Unread Announcements';
      case AnnStatusFilter.read:
        return 'Read Announcements';
      case AnnStatusFilter.recent:
        return 'Recent Announcements';
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredAnnouncements;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Announcement',
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationPage()),
              );
            },
          ),
        ],
      ),

      // ↓↓↓ Add button bottom-right
      floatingActionButton: AddButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AnnouncementForm(requestType: ''),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== TOP BAR: Search + Classification + Status ==========
                SearchAndFilterBar(
                  searchController: _searchController,
                  selectedClassification: _selectedClassification,
                  classifications: _classifications,
                  onClassificationChanged: (v) =>
                      setState(() => _selectedClassification = v),

                  selectedStatus: _selectedStatus,
                  statuses: _statuses,
                  onStatusChanged: (v) => setState(() {
                    _selectedStatus = v;
                    _statusFilter = _toFilter(v);
                  }),

                  onSearchChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 16),

                // ===== Header only (Add button moved to bottom-right) =====
                Text(
                  headerTitle(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                // ===== List =====
                Expanded(
                  child: items.isEmpty
                      ? const EmptyState()
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final a = items[i];
                            final y = a.postedAt.year;
                            final m = a.postedAt.month.toString().padLeft(2, '0');
                            final d = a.postedAt.day.toString().padLeft(2, '0');
                            final dateStr = '$y-$m-$d';

                            return Opacity(
                              opacity: a.isRead ? 0.85 : 1,
                              child: Stack(
                                children: [
                                  AnnouncementCard(
                                    title: a.title,
                                    datePosted: dateStr,
                                    details: a.details,
                                    classification: a.classification,
                                    onTap: () {
                                      final idx = _all.indexOf(a);
                                      if (idx != -1 && !_all[idx].isRead) {
                                        setState(() => _all[idx] = _all[idx].copyWith(isRead: true));
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const AnnouncementDetails(
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  if (!a.isRead)
                                    const Positioned(
                                      top: 10,
                                      right: 10,
                                      child: UnreadDot(),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
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
