import 'package:flutter/material.dart';

class CustomTabHeader extends StatelessWidget {
  final VoidCallback? onBackTap;

  const CustomTabHeader({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100, // Height for the tab
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5), // Shadow below the tab
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: GestureDetector(
              onTap: onBackTap ?? () => Navigator.pop(context),
              child: const CircleAvatar(
                backgroundColor: Colors.black,
                radius: 22,
                child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}