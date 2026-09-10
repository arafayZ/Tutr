// lib/services/chat_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/chat_models.dart';

class ChatService {
  static Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ✅ NEW: Get or create SHARED chat room (one per student-tutor pair)
  static Future<ChatRoom> getOrCreateSharedChatRoom(int studentUserId, int tutorUserId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getSharedChatRoom}?studentId=$studentUserId&tutorId=$tutorUserId&userId=$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatRoom.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to get/create shared chat room');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  // ✅ EXISTING: Keep for backward compatibility (connection-based)
  static Future<ChatRoom> getOrCreateChatRoom(int connectionId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getChatRoom}/$connectionId?userId=$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatRoom.fromJson(data);
      } else {
        throw Exception('Failed to get chat room');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  static Future<List<ChatRoom>> getUserChatRooms(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUserChatRooms}/$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ChatRoom.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get chat rooms');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  static Future<Message> sendMessage(SendMessageRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sendMessage}'),
        headers: await _getHeaders(),
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  static Future<List<Message>> getMessages(int roomId, int userId, {int page = 0, int size = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getMessages}/$roomId?userId=$userId&page=$page&size=$size'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get messages');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  static Future<void> markAllAsRead(int roomId, int userId) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.markAsRead}/$roomId/read-all?userId=$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as read');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  static Future<int> getUnreadCount(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.getUnreadCount}/$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unreadCount'] ?? 0;
      } else {
        throw Exception('Failed to get unread count');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  static Future<void> deleteMessage(int messageId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deleteMessage}/$messageId?userId=$userId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        throw Exception('Failed to delete message');
      }
    } catch (e) {
      throw Exception('Error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  static Future<bool> isChatAvailable(int connectionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.checkChatAvailable}/$connectionId'),
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['isAvailable'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  // audio
  // ✅ Upload audio file to server
  static Future<String> uploadAudio(File audioFile, int userId) async {
    try {
      print('📤 Uploading audio: ${audioFile.path}');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadAudio}?userId=$userId'),
      );

      final headers = await _getHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.files.add(
        await http.MultipartFile.fromPath('file', audioFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Upload status: ${response.statusCode}');
      print('📡 Upload response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['audioUrl'];
      } else {
        throw Exception('Failed to upload audio: ${response.body}');
      }
    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception('Error uploading: ${e.toString()}');
    }
  }

  // ✅ Upload file to server
  static Future<Map<String, dynamic>> uploadFile(File file, int userId) async {
    try {
      print('📤 Uploading file: ${file.path}');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadFile}?userId=$userId'),
      );

      final headers = await _getHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Upload status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'fileUrl': data['fileUrl'],
          'fileName': data['fileName'],
          'fileSize': data['fileSize'],
          'fileType': data['fileType'],
        };
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Upload error: $e');
      throw Exception('Error uploading: ${e.toString()}');
    }
  }
}