import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';

class MyStudentsListScreen extends StatelessWidget {
  // 1. Receive the connections list from the previous screen
  final List<Map<String, dynamic>> connections;

  const MyStudentsListScreen({super.key, required this.connections});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,

      // --- MATCHED ENLARGED FAB ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: Column(
        children: [
          _buildHeader(context),

          const SizedBox(height: 20),

          // --- FILTERED STUDENT LIST ---
          Expanded(
            child: connections.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
              itemCount: connections.length,
              itemBuilder: (context, index) {
                // 2. Extract the name from the connection map
                final studentName = connections[index]['name'] ?? "Unknown Student";
                return _buildPersonTile(studentName);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),
          const Text(
            "My Students",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.search, color: Colors.black, size: 28),
          )
        ],
      ),
    );
  }

  Widget _buildPersonTile(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.black,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(70, 30),
            ),
            child: const Text("Details", style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          const Text(
            "No students found in connections",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}