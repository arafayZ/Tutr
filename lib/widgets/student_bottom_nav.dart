import 'package:flutter/material.dart';

class StudentBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StudentBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, letterSpacing: 0.5),
        items: [
          _buildNavItem(Icons.home_outlined, Icons.home, "HOME", 0),
          _buildNavItem(Icons.assignment_outlined, Icons.assignment, "CONNECTION", 1),
          _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, "INBOX", 2),
          _buildNavItem(Icons.favorite_border, Icons.favorite, "FAVOURITES", 3),
          _buildNavItem(Icons.person_outline, Icons.person, "PROFILE", 4),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData unselectedIcon,
      IconData selectedIcon,
      String label,
      int index,
      ) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Icon(currentIndex == index ? selectedIcon : unselectedIcon, size: 26),
      ),
      label: label,
    );
  }
}