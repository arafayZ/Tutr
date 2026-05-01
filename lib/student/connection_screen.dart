import 'package:flutter/material.dart';
import '../widgets/student_bottom_nav.dart';
import 'student_dashboard.dart';
import 'favourites_screen.dart';
import 'profile_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  bool isConnectedTab = true;
  int _selectedIndex = 1;

  // Search Logic
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  // Mock data for "Connected" tab
  final List<Map<String, dynamic>> connectedTutors = [
    {
      "name": "Emaz Ali Khan",
      "subject": "Physics",
      "price": "2500 PKR",
      "level": "Expert",
      "rating": "4.9",
      "status": "ONLINE",
      "color": Colors.blue.shade900,
      "isAvailable": true,
    },
    {
      "name": "Sumaika Asif",
      "subject": "UI/UX Design",
      "price": "2000 PKR",
      "level": "Senior",
      "rating": "4.8",
      "status": "ONLINE",
      "color": Colors.pink.shade900,
      "isAvailable": false,
    },
    {
      "name": "Muhammad Ali Imran",
      "subject": "Islamiyat",
      "price": "2200 PKR",
      "level": "Expert",
      "rating": "4.7",
      "status": "AWAY",
      "color": Colors.green.shade900,
      "isAvailable": true,
    },
    {
      "name": "Abdul Rafay",
      "subject": "Pakistan Studies",
      "price": "2200 PKR",
      "level": "Expert",
      "rating": "4.7",
      "status": "AWAY",
      "color": Colors.green.shade900,
      "isAvailable": true,
    },
  ];

  // Mock data for "My Bids" tab
  final List<Map<String, dynamic>> myBids = [
    {"name": "Ahmed Khan", "subject": "Physics"},
    {"name": "Asim Ali Khan", "subject": "Physics"},
    {"name": "Asim Ali Khan", "subject": "Physics"},
    {"name": "Asim Ali Khan", "subject": "Physics"},
    {"name": "Asim Ali Khan", "subject": "Physics"},
  ];

  void _handleNavigation(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const StudentDashboard();
        break;
      case 1:
        return;
      case 3:
        nextScreen = const FavouritesScreen();
        break;
      case 4:
        nextScreen = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which list to filter based on the active tab
    final currentList = isConnectedTab ? connectedTutors : myBids;
    final filteredList = currentList.where((item) {
      final name = item['name'].toString().toLowerCase();
      final subject = item['subject'].toString().toLowerCase();
      return name.contains(_searchQuery) || subject.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      bottomNavigationBar: StudentBottomNav(
        currentIndex: _selectedIndex,
        onTap: _handleNavigation,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  _buildSearchBar(),
                  const SizedBox(height: 15),
                  // Display the search result bar only when typing
                  if (_searchQuery.isNotEmpty) _buildResultBar(filteredList.length),
                  const SizedBox(height: 10),
                  _buildToggleButtons(),
                  const SizedBox(height: 20),
                  _buildContentList(filteredList),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Connections",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: const InputDecoration(
          hintText: "Search Message",
          prefixIcon: Icon(Icons.search, color: Colors.black, size: 28),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildResultBar(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF1A1C43), fontSize: 16, fontWeight: FontWeight.bold),
              children: [
                const TextSpan(text: "Result for "),
                TextSpan(
                  text: '"${_searchController.text}"',
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
          Text(
            "$count FOUNDS",
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Expanded(child: _toggleButton("Connected", isConnectedTab, () => setState(() => isConnectedTab = true))),
          const SizedBox(width: 15),
          Expanded(child: _toggleButton("My Bids", !isConnectedTab, () => setState(() => isConnectedTab = false))),
        ],
      ),
    );
  }

  Widget _toggleButton(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildContentList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Text("No results found", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    if (isConnectedTab) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildTutorCard(list[index]),
      );
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, thickness: 1, indent: 20, endIndent: 20),
          itemBuilder: (context, index) => _buildBidListItem(list[index]),
        ),
      );
    }
  }

  Widget _buildBidListItem(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C43))),
                Text(data['subject'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text("Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorCard(Map<String, dynamic> data) {
    return Container(
      height: 185,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            decoration: BoxDecoration(
              color: data['color'] ?? Colors.grey,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data['name'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                      if (data['isAvailable'] == false)
                        const Text("Unavailable", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  Text(data['subject'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43))),
                  Row(
                    children: [
                      Text(data['price'] ?? "", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(data['level'] ?? "", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      Text(" ${data['rating'] ?? "0.0"}   |   ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(data['status'] ?? "", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                    ],
                  ),
                  Row(
                    children: [
                      _cardButton("Disconnect", const Color(0xFFE5E7EB), Colors.black),
                      const SizedBox(width: 8),
                      _cardButton("Message", Colors.black, Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardButton(String label, Color bg, Color text) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: text,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}