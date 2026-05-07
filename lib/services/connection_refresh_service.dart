import 'dart:async';
import 'package:flutter/foundation.dart';

class ConnectionRefreshService {
  static final ConnectionRefreshService _instance = ConnectionRefreshService._internal();
  factory ConnectionRefreshService() => _instance;
  ConnectionRefreshService._internal();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onRefreshConnections => _controller.stream;

  void notifyRefresh() {
    _controller.add(true);
  }

  void dispose() {
    _controller.close();
  }
}