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
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),

          // 🔥 stronger + layered shadow (key fix)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 0),
            _buildNavItem(Icons.assignment_outlined, Icons.assignment, 1),
            _buildNavItem(Icons.chat_bubble_outline, Icons.chat_bubble, 2),
            _buildNavItem(Icons.favorite_border, Icons.favorite, 3),
            _buildNavItem(Icons.person_outline, Icons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData unselectedIcon, IconData selectedIcon, int index) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1.1 : 1.0,
        child: CircleAvatar(
          radius: 23,
          backgroundColor:
          isSelected ? Colors.black : Colors.transparent,
          child: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            size: 22,
            color: isSelected
                ? Colors.white
                : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}