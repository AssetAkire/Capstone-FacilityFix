import 'package:flutter/material.dart';

// AppBar Widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; 
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      automaticallyImplyLeading: false,

      title: Padding(
        padding: const EdgeInsets.fromLTRB(8,0, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Leading section: Icon or Text
            if (leading != null)
              leading!
            else
              const SizedBox(),

            // Title section (optional)
            if (title != null)
              Expanded(
                child: Center(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              const Spacer(),

            // Actions/Icons
            if (actions != null && actions!.isNotEmpty)
              Row(children: actions!)
            else
              const SizedBox(),
          ],
        ),
      ),
      
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: const Color(0xFFDDDEE0), // Divider color
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
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
