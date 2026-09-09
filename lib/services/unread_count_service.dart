// lib/services/unread_count_service.dart
import 'dart:async';

class UnreadCountService {
  static final UnreadCountService _instance = UnreadCountService._internal();
  factory UnreadCountService() => _instance;
  UnreadCountService._internal();

  final _unreadCountController = StreamController<int>.broadcast();
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  int _currentCount = 0;

  void updateUnreadCount(int count) {
    _currentCount = count;
    _unreadCountController.add(count);
  }

  int getCurrentCount() {
    return _currentCount;
  }

  void dispose() {
    _unreadCountController.close();
  }
}