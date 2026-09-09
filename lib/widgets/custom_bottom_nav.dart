import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../services/unread_count_service.dart';
import '../models/chat_models.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    this.currentIndex = -1,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
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

    print('🔍 BottomNav - User ID: $_userId');

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
        print('🔴 BottomNav - Unread count updated via service: $_unreadCount');
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
          // ✅ Also update the service
          UnreadCountService().updateUnreadCount(unreadCount);
          print('🔴 BottomNav - Unread count: $_unreadCount');
        }
      } catch (e) {
        print('❌ Error loading unread count: $e');
      }
    }
  }

  void _connectWebSocket() {
    if (_userId > 0) {
      print('🔌 Connecting WebSocket for bottom nav - User: $_userId');

      WebSocketService.instance.connect(_userId);
      WebSocketService.instance.removeListener(_onNewMessage);
      WebSocketService.instance.addListener(_onNewMessage);

      print('✅ WebSocket listener registered for bottom nav');
    }
  }

  void _onNewMessage(Message message) {
    print('📩 New message received in bottom nav - Updating badge');
    if (mounted) {
      _loadUnreadCount();
    }
  }

  // ✅ Method to refresh unread count from outside
  Future<void> refreshUnreadCount() async {
    await _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: BottomAppBar(
        padding: EdgeInsets.zero,
        color: Colors.white,
        elevation: 20,
        notchMargin: 10,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_outlined, "HOME", '/tutor_dashboard'),
              _buildNavItem(context, 1, Icons.people_outline, "CONNECTION", '/connection'),
              const SizedBox(width: 45),
              _buildNavItemWithBadge(context, 2, Icons.chat_bubble_outline, "INBOX", '/inbox'),
              _buildNavItem(context, 3, Icons.person_outline, "PROFILE", '/profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, String route) {
    final bool isActive = widget.currentIndex == index;
    final Color color = isActive ? Colors.black : Colors.grey;

    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            route,
                (Route<dynamic> route) => route.isFirst,
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemWithBadge(BuildContext context, int index, IconData icon, String label, String route) {
    final bool isActive = widget.currentIndex == index;
    final Color color = isActive ? Colors.black : Colors.grey;

    return InkWell(
      onTap: () {
        if (!isActive) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            route,
                (Route<dynamic> route) => route.isFirst,
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 26),
              if (_unreadCount > 0)
                Positioned(
                  right: -6,
                  top: -4,
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
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}