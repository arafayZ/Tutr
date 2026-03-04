import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    // We wrap the BottomAppBar in a Container with a white color.
    // This ensures that the 'cut-out' area of the notch shows white
    // instead of the screen background (transparency).
    return Container(
      color: Colors.white,
      child: BottomAppBar(
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 20,
        notchMargin: 10,
        // The notch follows the FAB shape
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                icon: Icons.home_outlined,
                label: "HOME",
                active: true, // You can make this dynamic based on the current route
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/tutor_dashboard');
                },
              ),
              const NavItem(icon: Icons.people_outline, label: "CONNECTION", active: false),

              // This is the gap where the FAB sits.
              // The notch is drawn around this space.
              const SizedBox(width: 45),

              const NavItem(icon: Icons.chat_bubble_outline, label: "INBOX", active: false),
              const NavItem(icon: Icons.person_outline, label: "PROFILE", active: false),
            ],
          ),
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Active color changed to Tutor Black, Inactive to Grey
    final Color color = active ? Colors.black : Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}