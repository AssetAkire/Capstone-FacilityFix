import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showMore;
  final bool showHistory;

  const CustomAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.showMore = false,
    this.showHistory = false,
  }) : super(key: key);

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              if (showHistory) ...[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.history, color: Colors.blue),
                  ),
                  title: const Text('View History'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
              ],

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: const Icon(Icons.edit, color: Colors.green),
                ),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),

              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm Delete',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Are you sure you want to delete this item?'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF005CE8),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false, 
      titleSpacing: 0,   
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24), // ⬅️ 24px both sides
        child: Row(
          children: [
            if (leading != null) leading! else const SizedBox(width: 8),
            if (title != null)
              Text(
                title!,
                style: const TextStyle(
                  color: Color(0xFF101828),
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
          ],
        ),
      ),

      // Actions 
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24), 
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actions != null && actions!.isNotEmpty) ...actions!,
              if (showMore)
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF005CE8)),
                  onPressed: () => _showBottomSheet(context),
                ),
            ],
          ),
        ),
      ],

      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFFDDDEE0),
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

// Navigation Bar
class NavBar extends StatefulWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

    @override
    State<NavBar> createState() => _NavBarState();
    Size get preferredSize => const Size.fromHeight(70);
  }

  // Navigation Bar Widget
  class _NavBarState extends State<NavBar> {
    @override
    Widget build(BuildContext context) {
      return BottomNavigationBar(
        backgroundColor: Colors.blue.shade100,
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        items: widget.items.asMap().entries.map((entry) {
          int index = entry.key;
          NavItem item = entry.value;
          bool isSelected = index == widget.currentIndex;

          return BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                child: Icon(
                  item.icon,
                  color: isSelected ? const Color(0xFF005CE8) : const Color(0xFF494949),
                ),
              ),
              label: '',
            );
        }).toList(),
        selectedItemColor: const Color(0xFF005CE8),
        unselectedItemColor: const Color(0xFF494949),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      );
    }
  }

  class NavItem {
    final IconData icon;

    const NavItem({required this.icon});
  }
