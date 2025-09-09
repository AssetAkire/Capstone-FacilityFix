import 'package:facilityfix/admin/announcement.dart';
import 'package:facilityfix/admin/calendar.dart';
import 'package:facilityfix/admin/home.dart';
import 'package:facilityfix/admin/inventory.dart';
import 'package:facilityfix/admin/workorder.dart';
import 'package:facilityfix/widgets/helper_models.dart';
import 'package:facilityfix/widgets/modals.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/view_details.dart';
import 'package:facilityfix/widgets/buttons.dart' as custom_buttons; // ⬅️ custom buttons

class InventoryDetails extends StatefulWidget {
  final String selectedTabLabel;

  const InventoryDetails({
    super.key,
    required this.selectedTabLabel,
  });

  @override
  State<InventoryDetails> createState() => _InventoryDetailsState();
}

class _InventoryDetailsState extends State<InventoryDetails> {
  int _selectedIndex = 4;

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
    }
  }

  bool get _isInventoryDetails =>
      widget.selectedTabLabel.toLowerCase() == 'inventory details';
  bool get _isInventoryRequest =>
      widget.selectedTabLabel.toLowerCase() == 'inventory request';

  // ===== Current item context (demo data) =====
  String? get _currentItemName {
    if (_isInventoryDetails) return "Galvanized Screw 3mm";
    return null;
  }

  String? get _currentItemId {
    if (_isInventoryDetails) return "INV-2025-014";
    return null;
  }

  String? get _currentUnit {
    if (_isInventoryDetails) return "pcs"; // from the details below
    return null;
  }

  // ----- Actions -----
  Future<void> _onRestock() async {
    final result = await showModalBottomSheet<RestockResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RestockBottomSheet(
        itemName: _currentItemName ?? '-',
        itemId: _currentItemId ?? '-',
        unit: _currentUnit ?? 'pcs',
      ),
    );

    if (result != null) {
      // TODO: backend update for restock
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restocked ${result.quantity} ${result.unit}'),
        ),
      );
    }
  }

  Future<void> _onReject() async {
    final result = await showModalBottomSheet<RejectResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RejectBottomSheet(),
    );

    if (result != null) {
      // TODO: backend update for rejection (status, reason, note)
      final note = (result.note == null || result.note!.trim().isEmpty)
          ? ''
          : ' — ${result.note}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request rejected • ${result.reason}$note')),
      );
    }
  }

  void _onAccept() {
    // TODO: backend update for acceptance
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request accepted.')),
    );
  }

  // ----- Sticky bars (no SafeArea bottom to avoid extra padding) -----
  Widget? _buildStickyBar() {
    if (_isInventoryDetails) {
      // Restock Button
      return SafeArea(
        top: false,
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Expanded(
                child: custom_buttons.FilledButton(
                  label: 'Restock',
                  onPressed: _onRestock,
                  withOuterBorder: false,
                  backgroundColor: const Color(0xFF1570EF),
                  height: 48,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isInventoryRequest) {
      // Reject + Accept
      return SafeArea(
        top: false,
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Expanded(
                child: custom_buttons.OutlinedPillButton(
                  icon: Icons.delete_outline,
                  label: 'Reject',
                  onPressed: _onReject,
                  height: 44,
                  borderRadius: 24,
                  foregroundColor: Colors.red,
                  borderColor: Colors.red,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: custom_buttons.FilledButton(
                  label: 'Accept',
                  onPressed: _onAccept,
                  withOuterBorder: false,
                  backgroundColor: const Color(0xFF1570EF),
                  height: 48,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildTabContent() {
    switch (widget.selectedTabLabel.toLowerCase()) {
      // Inventory Details
      case 'inventory details':
        return InventoryDetailsScreen(
          // Basic Information
          itemName: "Galvanized Screw 3mm",
          itemId: "INV-2025-014",
          status: "In Stock", // shows StatusTag

          // Item Details
          dateAdded: "01 / 09 / 25",
          classification: "Hardware",
          department: "Civil / Carpentry",

          // Stock
          stockStatus: "In Stock",
          quantity: "150 pcs",
          reorderLevel: "50 pcs",
          unit: "pcs", // <— this drives the automated unit in the sheet

          // Supplier
          supplierName: "Metro Hardware Supply",
          supplierNumber: "+63 912 345 6789",
          warrantyUntil: "12 / 12 / 26",
        );

      // Inventory Request
      case 'inventory request':
        return InventoryDetailsScreen(
          // Basic Information
          itemName: "Electrical Tape",
          itemId: " ",
          status: "Pending",

          // Request Item
          requestId: "REQ-ITM-2025-091",
          requestQuantity: "10",
          requestUnit: "rolls",
          dateNeeded: "15 / 09 / 25",
          reqLocation: "Tower B – Unit 12A",

          // Requestor
          staffName: "Juan Dela Cruz",
          staffDepartment: "Maintenance",

          // Notes
          notes: "Required for rewiring work in common hallways.",
        );

      default:
        return const Center(child: Text("No requests found."));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sticky = _buildStickyBar();
    final bool hasSticky = sticky != null;
    final bodyInsetBottom = hasSticky ? 120.0 : 24.0; 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Inventory Management',
        leading: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: BackButton(),
        ),
        showMore: true,
        showHistory: !_isInventoryRequest, // false on the request tab
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bodyInsetBottom),
          child: _buildTabContent(),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sticky != null) sticky,
          NavBar(
            items: _navItems,
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
          ),
        ],
      ),
    );
  }
}
