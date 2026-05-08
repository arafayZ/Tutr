import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'add_course_screen.dart';
import 'chat_details_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // Mock data representing current conversations
  final List<Map<String, dynamic>> _allMessages = [
    {"name": "Bilal Raza", "msg": "Hi, Good Evening Bro.!", "time": "14:59", "count": "03"},
    {"name": "Fatima Iqbal", "msg": "I Just Finished It.!", "time": "06:35", "count": "02"},
    {"name": "Hassan Javed", "msg": "How are you?", "time": "08:10", "count": ""},
    {"name": "Ali Khan", "msg": "OMG, This is Amazing..", "time": "21:07", "count": "05"},
    {"name": "Ahmed Malik", "msg": "Wow, This is Really Epic", "time": "09:15", "count": ""},
    {"name": "Bilal Ahmed", "msg": "Hi, Good Evening Bro.!", "time": "14:59", "count": "03"},
  ];

  List<Map<String, dynamic>> _filteredMessages = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredMessages = List.from(_allMessages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMessages(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMessages = List.from(_allMessages);
      } else {
        _filteredMessages = _allMessages.where((message) {
          final name = message['name'].toString().toLowerCase();
          final msg = message['msg'].toString().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              msg.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,

      // --- CENTERED FAB ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // --- ROUNDED HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "Inbox",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterMessages,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: "Search Message",
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _filterMessages("");
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            // --- MESSAGES LIST CONTAINER ---
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  child: _filteredMessages.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 50, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          "No messages found",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 100),
                    itemCount: _filteredMessages.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 80,
                      color: Color(0xFFF1F1F1),
                    ),
                    itemBuilder: (context, index) {
                      final chat = _filteredMessages[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailsScreen(
                                userName: chat["name"],
                              ),
                            ),
                          );
                        },
                        child: _buildChatItem(chat),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Extra spacing to ensure content clears the bottom navigation area
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  // Builder for the individual chat row
  Widget _buildChatItem(Map<String, dynamic> chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: const CircleAvatar(
        radius: 28,
        backgroundColor: Colors.black,
        child: Icon(Icons.person, color: Colors.white, size: 30),
      ),
      title: Text(
        chat["name"],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        chat["msg"],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chat["count"] != "")
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF2979FF),
                shape: BoxShape.circle,
              ),
              child: Text(
                chat["count"],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            chat["time"],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}