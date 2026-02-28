import 'package:flutter/material.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  // Logic: Change this to true to see the "After Approval" screen
  bool isApproved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Black Header Background
          Container(
            height: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopProfileRow(),
                  const SizedBox(height: 20),
                  _buildStatCards(),
                  const SizedBox(height: 30),

                  // Content below depends on approval status
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Activity Center",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        _buildActivityCenter(),
                        const SizedBox(height: 40),

                        isApproved ? _buildApprovedContent() : _buildPendingContent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTopProfileRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with user image
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Good Morning", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text("Emaz Ali Khan", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.search, color: Colors.white, size: 28),
          const SizedBox(width: 15),
          const Icon(Icons.notifications_none, color: Colors.white, size: 28),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statCard("00", "Active Students", const [Color(0xFFE64D26), Color(0xFF8B2D17)]),
          const SizedBox(width: 15),
          _statCard("00", "Active Courses", const [Color(0xFF007EF2), Color(0xFF003D75)]),
        ],
      ),
    );
  }

  Widget _statCard(String count, String label, List<Color> colors) {
    return Expanded(
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(count, style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCenter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _activityIcon(Icons.person_outline, "Students"),
        _activityIcon(Icons.library_books_outlined, "Courses"),
        _activityIcon(Icons.gavel_outlined, "Bids"),
        _activityIcon(Icons.star_outline, "Reviews"),
      ],
    );
  }

  Widget _activityIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Icon(icon, size: 28, color: const Color(0xFF0D1B3E)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPendingContent() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.hourglass_empty, size: 100, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            "Your account is under review.\nSome features are limited until approval.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Top Courses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(Icons.cancel_outlined, size: 100, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              const Text("Nothing Here Yet", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(Icons.home, "HOME", true),
            _navIcon(Icons. people_outline, "CONNECTION", false),
            const SizedBox(width: 40), // Space for FAB
            _navIcon(Icons.chat_bubble_outline, "INBOX", false),
            _navIcon(Icons.person_outline, "PROFILE", false),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Colors.blue : Colors.grey, size: 24),
        Text(label, style: TextStyle(color: isActive ? Colors.blue : Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      onPressed: () {},
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: const Icon(Icons.add, color: Colors.blue, size: 30),
      ),
    );
  }
}