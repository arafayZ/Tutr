// import 'package:flutter/material.dart';
//
// class CustomBottomNav extends StatelessWidget {
//   // Add this variable to track which tab is active
//   final int currentIndex;
//
//   const CustomBottomNav({
//     super.key,
//     required this.currentIndex, // Make it required so you don't forget it
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       child: BottomAppBar(
//         padding: EdgeInsets.zero,
//         color: Colors.white,
//         elevation: 20,
//         notchMargin: 10,
//         shape: const CircularNotchedRectangle(),
//         child: SizedBox(
//           height: 65,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               NavItem(
//                 // Use filled icon if active, outlined if not
//                 icon: currentIndex == 0 ? Icons.home : Icons.home_outlined,
//                 label: "HOME",
//                 active: currentIndex == 0, // Only black if index is 0
//                 onTap: () {
//                   if (currentIndex != 0) {
//                     Navigator.pushReplacementNamed(context, '/tutor_dashboard');
//                   }
//                 },
//               ),
//               NavItem(
//                 icon: Icons.people_outline,
//                 label: "CONNECTION",
//                 active: currentIndex == 1,
//                 onTap: () {
//                   // Add connection navigation here
//                 },
//               ),
//
//               const SizedBox(width: 45),
//
//               NavItem(
//                 icon: Icons.chat_bubble_outline,
//                 label: "INBOX",
//                 active: currentIndex == 2,
//                 onTap: () {
//                   // Add inbox navigation here
//                 },
//               ),
//               NavItem(
//                 icon: currentIndex == 3 ? Icons.person : Icons.person_outline,
//                 label: "PROFILE",
//                 active: currentIndex == 3, // Only black if index is 3
//                 onTap: () {
//                   if (currentIndex != 3) {
//                     Navigator.pushReplacementNamed(context, '/ProfileScreen');
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class NavItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool active;
//   final VoidCallback? onTap;
//
//   const NavItem({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.active,
//     this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final Color color = active ? Colors.black : Colors.grey;
//
//     return InkWell(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: color, size: 26),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: color,
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  // 0: HOME, 1: CONNECTION, 2: INBOX, 3: PROFILE
  // Use -1 (default) to make all icons grey
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    this.currentIndex = -1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: BottomAppBar(
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 20,
        notchMargin: 10,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_outlined, "HOME", '/tutor_dashboard'),
              _buildNavItem(context, 1, Icons.people_outline, "CONNECTION", '/connections'),

              const SizedBox(width: 45), // FAB space

              _buildNavItem(context, 2, Icons.chat_bubble_outline, "INBOX", '/inbox'),
              _buildNavItem(context, 3, Icons.person_outline, "PROFILE", '/profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, String route) {
    // Only black if it's one of the 4 core screens
    final bool isActive = currentIndex == index;
    final Color color = isActive ? Colors.black : Colors.grey;

    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
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