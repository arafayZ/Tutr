import 'package:flutter/material.dart'; // Import Flutter material widgets

// Custom Bottom Navigation Bar widget
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white, // Background color of the bar
      elevation: 20, // Shadow under the bar
      notchMargin: 10, // Space for the FAB notch
      shape: const CircularNotchedRectangle(), // Creates the notch for FAB
      child: SizedBox(
        height: 60, // Height of bottom nav
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround, // Space items evenly
          children: [
            const NavItem(icon: Icons.home, label: "HOME", active: true), // Home button
            const NavItem(icon: Icons.people_outline, label: "CONNECTION", active: false), // Connection button
            const SizedBox(width: 40), // Empty space for center FAB
            const NavItem(icon: Icons.chat_bubble_outline, label: "INDEX", active: false), // Index button
            const NavItem(icon: Icons.person_outline, label: "PROFILE", active: false), // Profile button
          ],
        ),
      ),
    );
  }
}

// Single navigation item
class NavItem extends StatelessWidget {
  final IconData icon; // Icon for the item
  final String label; // Text label
  final bool active; // Is this item active?

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Colors.black; // Color if active
    final Color inactiveColor = Colors.grey; // Color if inactive

    return Column(
      mainAxisSize: MainAxisSize.min, // Wrap content vertically
      children: [
        Icon(
          icon, // Show icon
          color: active ? activeColor : inactiveColor, // Active/inactive color
          size: 24, // Icon size
        ),
        Text(
          label, // Show label
          style: TextStyle(
            color: active ? activeColor : inactiveColor, // Active/inactive color
            fontSize: 8, // Small font size
            fontWeight: FontWeight.bold, // Bold text
          ),
        ),
      ],
    );
  }
}