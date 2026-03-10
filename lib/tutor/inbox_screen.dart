import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import 'add_course_screen.dart';
import 'chat_details_screen.dart'; // Target screen for individual conversations

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // Mock data representing current conversations
  // 'count' represents unread messages; an empty string means no new notifications
  final List<Map<String, dynamic>> _messages = [
    {"name": "Bilal Raza", "msg": "Hi, Good Evening Bro.!", "time": "14:59", "count": "03"},
    {"name": "Fatima Iqbal", "msg": "I Just Finished It.!", "time": "06:35", "count": "02"},
    {"name": "Hassan Javed", "msg": "How are you?", "time": "08:10", "count": ""},
    {"name": "Ali Khan", "msg": "OMG, This is Amazing..", "time": "21:07", "count": "05"},
    {"name": "Ahmed Malik", "msg": "Wow, This is Really Epic", "time": "09:15", "count": ""},
    {"name": "Bilal Ahmed", "msg": "Hi, Good Evening Bro.!", "time": "14:59", "count": "03"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true, // Allows the list to scroll behind the curved bottom bar

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
        bottom: false, // Ensures the background color extends to the bottom of the screen
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
                child: const TextField(
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: "Search Message",
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
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
                  // Clips children to match the container's rounded top corners
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 100),
                    itemCount: _messages.length,
                    // Adds a thin line between chat items
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 80, // Aligns the line with the text, not the avatar
                      color: Color(0xFFF1F1F1),
                    ),
                    itemBuilder: (context, index) {
                      final chat = _messages[index];
                      // InkWell provides a visual ripple effect on tap
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatDetailsScreen(userName: chat["name"]),
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
      // CurrentIndex 2 highlights the 'Inbox' tab in your custom bar
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
        maxLines: 1, // Prevents text wrapping to multiple lines
        overflow: TextOverflow.ellipsis, // Adds '...' if message is too long
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Only show the unread badge if count is not empty
          if (chat["count"] != "")
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF2979FF), // Bright blue badge
                shape: BoxShape.circle,
              ),
              child: Text(
                chat["count"],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            chat["time"],
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54
            ),
          ),
        ],
      ),
    );
  }
}