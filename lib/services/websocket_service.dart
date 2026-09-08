// lib/services/websocket_service.dart
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';  // ✅ CORRECT IMPORT
import '../config/api_config.dart';
import '../models/chat_models.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  WebSocketService._();

  StompClient? _client;
  bool _isConnected = false;
  int _currentUserId = 0;
  final List<Function(Message)> _messageListeners = [];
  bool _isConnecting = false;

  bool get isConnected => _isConnected;
  int get currentUserId => _currentUserId;

  void connect(int userId) {
    if (_isConnected && _currentUserId == userId) return;
    if (_isConnecting) return;

    _currentUserId = userId;
    _disconnect();

    _isConnecting = true;

    try {
      final url = ApiConfig.wsUrl;
      print('🔌 WebSocket connecting to: $url for user: $userId');

      _client = StompClient(
        config: StompConfig(
          url: url,
          connectionTimeout: const Duration(seconds: 10),
          onConnect: (frame) {
            _isConnected = true;
            _isConnecting = false;
            print('✅ WebSocket connected successfully for user: $userId');
            _subscribeToUserQueue(userId);
          },
          onDisconnect: (frame) {
            print('🔌 WebSocket disconnected');
            _isConnected = false;
            _isConnecting = false;
          },
          onWebSocketError: (error) {
            print('🔌 WebSocket error: $error');
            _isConnected = false;
            _isConnecting = false;
            Future.delayed(const Duration(seconds: 5), () {
              if (!_isConnected && !_isConnecting) {
                print('🔌 Attempting to reconnect...');
                connect(_currentUserId);
              }
            });
          },
          onDebugMessage: (message) {
            // Uncomment for debugging
            // print('🔍 STOMP Debug: $message');
          },
          heartbeatOutgoing: const Duration(seconds: 5),
          heartbeatIncoming: const Duration(seconds: 5),
        ),
      );

      _client!.activate();

      Future.delayed(const Duration(seconds: 10), () {
        if (!_isConnected) {
          _isConnecting = false;
          print('❌ WebSocket connection timeout');
        }
      });

    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      _isConnected = false;
      _isConnecting = false;
      Future.delayed(const Duration(seconds: 5), () {
        if (!_isConnected && !_isConnecting) {
          print('🔌 Attempting to reconnect...');
          connect(_currentUserId);
        }
      });
    }
  }

  void _subscribeToUserQueue(int userId) {
    if (_client == null || !_isConnected) return;

    _client!.subscribe(
      destination: '/user/$userId/queue/messages',
      callback: (frame) {
        try {
          if (frame.body == null) return;
          final data = json.decode(frame.body!);
          final messageObj = Message.fromJson(data);
          messageObj.isOwn = messageObj.senderId == _currentUserId;
          _notifyListeners(messageObj);
        } catch (e) {
          print('Error parsing message: $e');
        }
      },
    );
    print('📡 Subscribed to: /user/$userId/queue/messages');
  }

  void sendMessage(Message message) {
    if (_client == null || !_isConnected) {
      print('⚠️ WebSocket not connected, message will be sent via API only');
      return;
    }

    final payload = json.encode({
      'chatRoomId': message.chatRoomId,
      'senderId': message.senderId,
      'recipientId': message.recipientId,
      'content': message.content,
    });

    _client!.send(
      destination: '/app/chat/send',
      body: payload,
    );
    print('📤 WebSocket message sent');
  }

  void addListener(Function(Message) listener) {
    if (!_messageListeners.contains(listener)) {
      _messageListeners.add(listener);
    }
  }

  void removeListener(Function(Message) listener) {
    _messageListeners.remove(listener);
  }

  void _notifyListeners(Message message) {
    for (var listener in _messageListeners) {
      listener(message);
    }
  }

  void disconnect() {
    _disconnect();
  }

  void _disconnect() {
    _isConnecting = false;
    if (_client != null) {
      try {
        _client!.deactivate();
      } catch (e) {
        print('Error disconnecting: $e');
      }
      _client = null;
    }
    _isConnected = false;
    _messageListeners.clear();
    print('🔌 WebSocket disconnected');
  }
}