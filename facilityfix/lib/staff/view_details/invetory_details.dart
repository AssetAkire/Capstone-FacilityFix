import 'package:facilityfix/staff/announcement.dart';
import 'package:facilityfix/staff/calendar.dart';
import 'package:facilityfix/staff/home.dart';
import 'package:facilityfix/staff/inventory.dart';
import 'package:facilityfix/staff/workorder.dart';
import 'package:flutter/material.dart';
import 'package:facilityfix/widgets/app&nav_bar.dart';
import 'package:facilityfix/widgets/view_details.dart';
import 'package:facilityfix/widgets/modals.dart'; // <-- CustomPopup
import 'package:facilityfix/widgets/buttons.dart'
    as custom_buttons; // <-- FilledButton lives here

class InventoryDetails extends StatefulWidget {
  final String selectedTabLabel;

  const InventoryDetails({super.key, required this.selectedTabLabel});

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

  // ───────────────────────────────────────────────────────────
  // Success dialog -> Announcements
  // ───────────────────────────────────────────────────────────
  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CustomPopup(
        title: 'Success',
        message:
            'Your item request has been submitted successfully and is now listed under Inventory Management.',
        primaryText: 'Go to Inventory Management',
        onPrimaryPressed: () {
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const InventoryPage()),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────
  // Modal: Request Item (quantity, date needed, optional notes)
  // ───────────────────────────────────────────────────────────
  Future<void> _openRequestItemSheet({
    required String itemName,
    required String itemId,
    required String defaultUnit,
  }) async {
    final formKey = GlobalKey<FormState>();
    final qtyCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? neededDate;

    Future<void> pickDate() async {
      final now = DateTime.now();
      final picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now, // can't be in the past
        lastDate: DateTime(now.year + 3),
      );
      if (picked != null) {
        setState(() {
          neededDate = DateTime(picked.year, picked.month, picked.day);
        });
      }
    }

    String _formatDate(DateTime d) {
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
      ];
      return '${months[d.month - 1]} ${d.day}, ${d.year}';
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  const Text(
                    'Request Item',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$itemName • $itemId',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF475467),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF344054),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter quantity',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (v) {
                            final s = (v ?? '').trim();
                            if (s.isEmpty) return 'Quantity is required';
                            final n = int.tryParse(s);
                            if (n == null || n <= 0) {
                              return 'Enter a positive whole number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          defaultUnit,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475467),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Date Needed
                  const Text(
                    'Date Needed',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF344054),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: pickDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Select date',
                          suffixIcon: const Icon(Icons.calendar_today_rounded),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (_) {
                          if (neededDate == null) return 'Date needed is required';
                          final now = DateTime.now();
                          final dd = DateTime(
                            neededDate!.year, neededDate!.month, neededDate!.day,
                          );
                          final today = DateTime(now.year, now.month, now.day);
                          if (dd.isBefore(today)) {
                            return 'Date cannot be in the past';
                          }
                          return null;
                        },
                        controller: TextEditingController(
                          text: neededDate == null ? '' : _formatDate(neededDate!),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Notes (Optional)
                  const Text(
                    'Notes (optional)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF344054),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add any remarks for this request',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Submit button
                  custom_buttons.FilledButton(
                    label: 'Submit Request',
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        final payload = {
                          'itemId': itemId,
                          'itemName': itemName,
                          'quantity': int.parse(qtyCtrl.text.trim()),
                          'unit': defaultUnit,
                          'dateNeeded': neededDate!.toIso8601String(),
                          'notes': notesCtrl.text.trim().isEmpty
                              ? null
                              : notesCtrl.text.trim(),
                          'requestedAt': DateTime.now().toIso8601String(),
                          'requestedBy': 'Current User', // TODO: bind to auth
                          'status': 'Pending',
                        };

                        Navigator.of(ctx).pop(); // close sheet
                        // Show success dialog and route to Announcements
                        _showRequestDialog(context);
                      }
                    },
                    height: 48,
                    borderRadius: 12,
                    backgroundColor: const Color(0xFF005CE7), // primary blue
                    withOuterBorder: false, // <-- remove outer border line
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Content (without the button; button is sticky in bottomNavigationBar)
  Widget _buildTabContent() {
    switch (widget.selectedTabLabel.toLowerCase()) {
      case 'inventory details':
        return InventoryDetailsScreen(
          // Basic Information
          itemName: "Galvanized Screw 3mm",
          itemId: "INV-2025-014",
          status: "In Stock",
          // Item Details
          dateAdded: "01 / 09 / 25",
          classification: "Hardware",
          department: "Civil / Carpentry",
          // Stock
          stockStatus: "In Stock",
          quantity: "150 pcs",
          reorderLevel: "50 pcs",
          unit: "pcs",
          // Supplier
          supplierName: "Metro Hardware Supply",
          supplierNumber: "+63 912 345 6789",
          warrantyUntil: "12 / 12 / 26",
        );

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

  // Sticky button builder (only for Inventory Details tab)
  Widget _buildStickyRequestBar() {
    // Match the details shown above
    const itemName = 'Galvanized Screw 3mm';
    const itemId = 'INV-2025-014';
    const defaultUnit = 'pcs';

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: custom_buttons.FilledButton(
            label: 'Request Item',
            onPressed: () => _openRequestItemSheet(
              itemName: itemName,
              itemId: itemId,
              defaultUnit: defaultUnit,
            ),
            borderRadius: 12,
            backgroundColor: const Color(0xFF005CE7), // primary blue
            withOuterBorder: false, // <-- remove outer border line
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Enough bottom padding so content never hides behind the sticky bar + nav
    const contentBottomPadding = 140.0;

    final lowerTab = widget.selectedTabLabel.toLowerCase();
    final showSticky = lowerTab == 'inventory details';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'View Details',
        leading: const Padding(
          padding: EdgeInsets.only(right: 8),
          child: BackButton(),
        ),
        showMore: true,
        showHistory: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, contentBottomPadding),
          child: _buildTabContent(),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSticky) _buildStickyRequestBar(),
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
