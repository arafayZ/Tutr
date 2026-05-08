import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
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
              _buildNavItem(context, 1, Icons.people_outline, "CONNECTION", '/connection'),
              const SizedBox(width: 45),
              _buildNavItem(context, 2, Icons.chat_bubble_outline, "INBOX", '/inbox'),
              _buildNavItem(context, 3, Icons.person_outline, "PROFILE", '/profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, String route) {
    final bool isActive = currentIndex == index;
    final Color color = isActive ? Colors.black : Colors.grey;

    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            route,
                (Route<dynamic> route) => route.isFirst,
          );
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