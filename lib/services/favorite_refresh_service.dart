import 'dart:async';

import 'package:flutter/foundation.dart';

class FavoriteRefreshService {
  static final FavoriteRefreshService _instance = FavoriteRefreshService._internal();
  factory FavoriteRefreshService() => _instance;
  FavoriteRefreshService._internal();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get onRefreshFavorites => _controller.stream;

  void notifyRefresh() {
    _controller.add(true);
  }

  void dispose() {
    _controller.close();
  }
}