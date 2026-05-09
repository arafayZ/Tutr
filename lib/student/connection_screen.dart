import 'package:flutter/material.dart';
import '../widgets/student_bottom_nav.dart';
import 'student_dashboard.dart';
import 'favourites_screen.dart';
import 'profile_screen.dart';
import '../tutor/chat_details_screen.dart';
import 'my_bid_details_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  bool isConnectedTab = true;
  int _selectedIndex = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<Map<String, dynamic>> connectedTutors = [
    {"name": "Emaz Ali Khan", "subject": "Physics", "price": "2500 PKR", "level": "Expert", "rating": "4.9", "status": "ONLINE", "color": Colors.blue.shade900, "isAvailable": true},
    {"name": "Sumaika Asif", "subject": "UI/UX Design", "price": "2000 PKR", "level": "Senior", "rating": "4.8", "status": "ONLINE", "color": Colors.pink.shade900, "isAvailable": false},
    {"name": "Muhammad Ali Imran", "subject": "Islamiyat", "price": "2200 PKR", "level": "Expert", "rating": "4.7", "status": "AWAY", "color": Colors.green.shade900, "isAvailable": true},
    {"name": "Abdul Rafay", "subject": "Pakistan Studies", "price": "2200 PKR", "level": "Expert", "rating": "4.7", "status": "AWAY", "color": Colors.green.shade900, "isAvailable": true},
  ];

  final List<Map<String, dynamic>> myBids = [
    {"name": "Ahmed Khan", "subject": "Physics"},
    {"name": "Asim Ali Khan", "subject": "Physics"},
    {"name": "Abdul Rafay", "subject": "Maths"},
    {"name": "Ali Khan", "subject": "Chemistry"},
    {"name": "Wasif Ali Wasif", "subject": "Physics"},
  ];

  // 1. Initial Confirmation Dialog (from image_821a96.png)
  void _confirmDisconnect(String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Are you sure you want to disconnect?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C43)),
          ),
          content: const Text(
            "This will end your current connection and stop further communication.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(color: Color(0xFF1A1C43), fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close confirm dialog
                _executeDisconnect(name); // Proceed to disconnect
              },
              child: const Text("DISCONNECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 2. Execution and Success Feedback
  void _executeDisconnect(String name) {
    setState(() {
      connectedTutors.removeWhere((tutor) => tutor['name'] == name);
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          if (Navigator.canPop(dialogContext)) Navigator.pop(dialogContext);
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              const Text("Disconnected!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text("You have successfully disconnected from $name.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }

  void _handleNavigation(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    Widget nextScreen;
    switch (index) {
      case 0: nextScreen = const StudentDashboard(); break;
      case 1: return;
      case 3: nextScreen = const FavouritesScreen(); break;
      case 4: nextScreen = const ProfileScreen(); break;
      default: return;
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
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
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4)
          )
        ],
      ),
      child: const Center(child: Text("Connections", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8)
          )
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
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
                TextSpan(text: '"${_searchController.text}"', style: const TextStyle(color: Colors.blue)),
              ],
            ),
          ),
          // Matches image_4c95d1.png
          Text("$count FOUNDS", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 13)),
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
          child: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildContentList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("No results found", style: TextStyle(color: Colors.grey))));
    }

    if (isConnectedTab) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildTutorCard(list[index]),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.withValues(alpha: 0.1),
          height: 1,
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) => _buildBidListItem(list[index]),
      ),
    );
  }

  Widget _buildBidListItem(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Colors.black),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? "Pending Tutor",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C43)),
                ),
                const SizedBox(height: 4),
                Text(
                  data['subject'] ?? "Mathematics",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 35,
            child: ElevatedButton(
              onPressed: () {
                // UPDATED: Navigate to MyBidDetailsScreen
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyBidDetailsScreen(bidData: data))
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text("Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)
            )
          ]
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
                width: 100,
                decoration: BoxDecoration(
                    color: data['color'],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), bottomLeft: Radius.circular(25))
                )
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['name'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(data['subject'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(data['price'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _cardButton("Disconnect", const Color(0xFFE5E7EB), Colors.black, () => _confirmDisconnect(data['name'])),
                        const SizedBox(width: 8),
                        _cardButton("Message", Colors.black, Colors.white, () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailsScreen(userName: data['name'])));
                        }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardButton(String label, Color bg, Color text, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: text,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
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