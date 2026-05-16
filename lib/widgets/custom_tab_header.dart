import 'package:flutter/material.dart';

/// A reusable Header widget with a white background, rounded bottom corners,
/// and a back button. This should be the only widget in this file.
class CustomTabHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackTap; // Optional callback for the back button
  final Widget? title; // Optional title if you want to add text later

  const CustomTabHeader({
    super.key,
    this.onBackTap,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100, // Fixed height for the header
      decoration: const BoxDecoration(
        color: Colors.white, // Pure white background
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30), // Rounded corners per your design
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12, // Light shadow for depth
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Back Button
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: GestureDetector(
                  onTap: onBackTap ?? () => Navigator.pop(context),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black, // High contrast black circle
                    radius: 22,
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            // Centered Title (Optional addition)
            if (title != null)
              Center(child: title),
          ],
        ),
      ),
    );
  }

  // This allows the widget to be used in the 'preferredSize' property of a Scaffold
  @override
  Size get preferredSize => const Size.fromHeight(100);
}