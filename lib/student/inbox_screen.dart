// lib/student/inbox_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../services/unread_count_service.dart'; // ✅ Add this
import '../models/chat_models.dart';
import '../config/api_config.dart';
import 'chat_details_screen.dart';

class StudentInboxScreen extends StatefulWidget {
  const StudentInboxScreen({super.key});

  @override
  State<StudentInboxScreen> createState() => _StudentInboxScreenState();
}

class _StudentInboxScreenState extends State<StudentInboxScreen> {
  List<ChatRoom> _chatRooms = [];
  List<ChatRoom> _filteredRooms = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  int _userId = 0;
  int _totalUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    WebSocketService.instance.removeListener(_onNewMessage);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print('🔍 All SharedPreferences values:');
    print('   userId: ${prefs.getInt('userId')}');
    print('   profileId: ${prefs.getInt('profileId')}');
    print('   userRole: ${prefs.getString('userRole')}');

    setState(() {
      _userId = prefs.getInt('userId') ?? 0;
      if (_userId == 0) {
        _userId = prefs.getInt('profileId') ?? 0;
      }
    });

    print('🔍 Student _userId: $_userId');

    await _loadChatRooms();
    _connectWebSocket();
  }

  Future<void> _loadChatRooms() async {
    setState(() => _isLoading = true);
    try {
      print('📡 Fetching chat rooms for student userId: $_userId');

      final rooms = await ChatService.getUserChatRooms(_userId);

      print('📊 Loaded ${rooms.length} chat rooms');
      for (var room in rooms) {
        print('   Room: id=${room.id}, tutor=${room.tutorName}, unread=${room.unreadCount}');
      }

      final totalUnread = await ChatService.getUnreadCount(_userId);
      print('📊 Total unread: $totalUnread');

      // ✅ Update unread count in service (for bottom nav badge)
      UnreadCountService().updateUnreadCount(totalUnread);

      setState(() {
        _chatRooms = rooms;
        _filteredRooms = List.from(rooms);
        _totalUnreadCount = totalUnread;
        _isLoading = false;
      });

      if (rooms.isEmpty) {
        print('⚠️ No chat rooms found for student $_userId');
      }

    } catch (e) {
      print('❌ Error loading chat rooms: $e');
      setState(() => _isLoading = false);
    }
  }

  void _connectWebSocket() {
    if (_userId > 0) {
      print('🔌 Connecting WebSocket for student inbox - User: $_userId');

      WebSocketService.instance.connect(_userId);
      WebSocketService.instance.removeListener(_onNewMessage);
      WebSocketService.instance.addListener(_onNewMessage);

      print('✅ WebSocket listener registered for student inbox');
    }
  }

  void _onNewMessage(Message message) {
    print('📩 New message received in student inbox: ${message.content}');
    print('📩 ChatRoom ID: ${message.chatRoomId}');

    if (mounted) {
      _loadChatRooms();
    }
  }

  void _filterRooms(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRooms = List.from(_chatRooms);
      } else {
        _filteredRooms = _chatRooms.where((room) {
          final name = room.tutorName.toLowerCase();
          final course = room.courseName.toLowerCase();
          final lastMsg = room.lastMessage?.toLowerCase() ?? '';
          return name.contains(query.toLowerCase()) ||
              course.contains(query.toLowerCase()) ||
              lastMsg.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);
    final diff = today.difference(date).inDays;

    int hour = time.hour;
    final minute = time.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;
    final timeStr = "$hour12:${minute.toString().padLeft(2, '0')} $amPm";

    if (diff == 0) {
      return timeStr;
    } else if (diff == 1) {
      return "Yesterday";
    } else if (diff < 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[time.weekday - 1];
    } else {
      return "${date.day}/${date.month}/${date.year}";
    }
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
            _buildHeader(),
            _buildSearchBar(),
            if (_searchController.text.isNotEmpty) _buildResultBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.black))
                  : _filteredRooms.isEmpty
                  ? _buildEmptyState()
                  : Container(
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
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(0, 10, 0, bottomPadding + 80),
                    itemCount: _filteredRooms.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 80,
                      color: Color(0xFFF1F1F1),
                    ),
                    itemBuilder: (context, index) {
                      final room = _filteredRooms[index];
                      return InkWell(
                        onTap: () async {
                          await ChatService.markAllAsRead(room.id, _userId);

                          print('🔍 Opening chat with tutor: ${room.tutorName}');
                          print('   tutorId: ${room.tutorId}');
                          print('   tutorUserId: ${room.tutorUserId}');
                          print('   studentId: $_userId');
                          print('   studentUserId: ${room.studentUserId}');

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StudentChatDetailsScreen(
                                userName: room.tutorName,
                                userImage: room.tutorImage,
                                tutorId: room.tutorId,
                                tutorUserId: room.tutorUserId ?? room.tutorId,
                                studentId: _userId,
                                studentUserId: room.studentUserId ?? _userId,
                                chatRoomId: room.id,
                                connectionId: room.connectionId,
                              ),
                            ),
                          );

                          await _loadChatRooms();
                        },
                        child: _buildChatItem(room),
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

  Widget _buildHeader() {
    return Container(
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
          onChanged: _filterRooms,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            hintText: "Search Tutors...",
            prefixIcon: const Icon(Icons.search, color: Colors.black),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _filterRooms("");
              },
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildResultBar() {
    return Padding(
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
                  text: _searchController.text,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const TextSpan(text: "\""),
              ],
            ),
          ),
          Text(
            "${_filteredRooms.length} found",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
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
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No messages yet",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Chat with tutors after connecting",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatRoom room) {
    final image = room.tutorImage;
    final name = room.tutorName;
    final unreadCount = room.unreadCount ?? 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.black,
        backgroundImage: image != null && image.isNotEmpty
            ? NetworkImage('${ApiConfig.baseUrl}$image')
            : null,
        child: image == null || image.isEmpty
            ? const Icon(Icons.person, color: Colors.white, size: 30)
            : null,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        room.lastMessage ?? "No messages yet",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (room.lastMessageAt != null)
            Text(
              _formatTime(room.lastMessageAt!),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          const SizedBox(height: 4),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2979FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}