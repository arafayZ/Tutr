import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../services/unread_count_service.dart';
import '../models/chat_models.dart';

class StudentBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const StudentBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<StudentBottomNav> createState() => _StudentBottomNavState();
}

class _StudentBottomNavState extends State<StudentBottomNav> {
  int _unreadCount = 0;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    WebSocketService.instance.removeListener(_onNewMessage);
    super.dispose();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId') ?? 0;
      if (_userId == 0) {
        _userId = prefs.getInt('profileId') ?? 0;
      }
    });

    print('🔍 Student BottomNav - User ID: $_userId');

    // ✅ Load initial unread count
    await _loadUnreadCount();

    // ✅ Connect to WebSocket for real-time updates
    _connectWebSocket();

    // ✅ Listen to unread count updates from UnreadCountService
    UnreadCountService().unreadCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
        print('🔴 Student BottomNav - Unread count updated via service: $_unreadCount');
      }
    });
  }

  Future<void> _loadUnreadCount() async {
    if (_userId > 0) {
      try {
        final unreadCount = await ChatService.getUnreadCount(_userId);
        if (mounted) {
          setState(() {
            _unreadCount = unreadCount;
          });
          UnreadCountService().updateUnreadCount(unreadCount);
          print('🔴 Student BottomNav - Unread count: $_unreadCount');
        }
      } catch (e) {
        print('❌ Error loading unread count: $e');
      }
    }
  }

  void _connectWebSocket() {
    if (_userId > 0) {
      print('🔌 Connecting WebSocket for student bottom nav - User: $_userId');

      WebSocketService.instance.connect(_userId);
      WebSocketService.instance.removeListener(_onNewMessage);
      WebSocketService.instance.addListener(_onNewMessage);

      print('✅ WebSocket listener registered for student bottom nav');
    }
  }

  void _onNewMessage(Message message) {
    print('📩 New message received in student bottom nav - Updating badge');
    if (mounted) {
      _loadUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 40,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_outlined, Icons.home, 0),
            _buildNavItem(Icons.assignment_outlined, Icons.assignment, 1),
            _buildNavItemWithBadge(Icons.chat_bubble_outline, Icons.chat_bubble, 2),
            _buildNavItem(Icons.favorite_border, Icons.favorite, 3),
            _buildNavItem(Icons.person_outline, Icons.person, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData unselectedIcon, IconData selectedIcon, int index) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1.1 : 1.0,
        child: CircleAvatar(
          radius: 23,
          backgroundColor: isSelected ? Colors.black : Colors.transparent,
          child: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            size: 22,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
      IconData unselectedIcon, IconData selectedIcon, int index) {
    final isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1.1 : 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor: isSelected ? Colors.black : Colors.transparent,
              child: Icon(
                isSelected ? selectedIcon : unselectedIcon,
                size: 22,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            // ✅ Unread count badge
            if (_unreadCount > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}