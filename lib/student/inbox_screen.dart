import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_details_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  // Original messages list with tutorId and studentId
  final List<Map<String, dynamic>> _allMessages = [
    {"name": "Bilal Raza", "msg": "Hi, Good Evening Bro.!", "time": "14:59", "count": "03", "tutorId": 1, "studentId": 101},
    {"name": "Fatima Iqbal", "msg": "I Just Finished It.!", "time": "06:35", "count": "02", "tutorId": 2, "studentId": 101},
    {"name": "Hassan Javed", "msg": "How are you?", "time": "08:10", "count": "", "tutorId": 3, "studentId": 101},
    {"name": "Ali Khan", "msg": "OMG, This is Amazing..", "time": "21:07", "count": "05", "tutorId": 4, "studentId": 101},
    {"name": "Ahmed Malik", "msg": "Wow, This is Really Epic", "time": "09:15", "count": "", "tutorId": 5, "studentId": 101},
    {"name": "Bilal Ahmed", "msg": "Hi, Good Evening Bro.!", "time": "14:59", "count": "03", "tutorId": 6, "studentId": 101},
  ];

  // Filtered messages list for display
  List<Map<String, dynamic>> _filteredMessages = [];

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  // Search query
  String _searchQuery = "";

  int _studentId = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentId = prefs.getInt('profileId') ?? 0;
      // Update studentId in all messages
      for (var message in _allMessages) {
        message['studentId'] = _studentId;
      }
      _filteredMessages = List.from(_allMessages);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMessages(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();

      if (_searchQuery.isEmpty) {
        _filteredMessages = List.from(_allMessages);
      } else {
        _filteredMessages = _allMessages.where((message) {
          final name = message["name"].toString().toLowerCase();
          final msg = message["msg"].toString().toLowerCase();
          return name.contains(_searchQuery) || msg.contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
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
                    color: Colors.black.withOpacity(0.08),
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterMessages,
                  cursorColor: Colors.black,
                  decoration: const InputDecoration(
                    hintText: "Search Message",
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    suffixIcon: Icon(Icons.filter_list, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),

            // Search Result Bar (shows when searching)
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                        children: [
                          const TextSpan(text: "Results for \""),
                          TextSpan(
                            text: _searchQuery,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          const TextSpan(text: "\""),
                        ],
                      ),
                    ),
                    Text(
                      "${_filteredMessages.length} found",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

            // Messages List
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
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No messages found",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Try a different search term",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: false,
                    padding: EdgeInsets.fromLTRB(0, 10, 0, bottomPadding + 80),
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
                                tutorId: chat["tutorId"],
                                studentId: chat["studentId"],
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
          ],
        ),
      ),
    );
  }

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