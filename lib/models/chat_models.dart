// lib/models/chat_models.dart
class ChatRoom {
  final int id;
  final String roomId;
  final int connectionId;
  final int studentId;
  final int studentUserId;
  final String studentName;
  final String? studentImage;
  final int tutorId;
  final int tutorUserId;
  final String tutorName;
  final String? tutorImage;
  final String courseName;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isActive;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.roomId,
    required this.connectionId,
    required this.studentId,
    required this.studentUserId,
    required this.studentName,
    this.studentImage,
    required this.tutorId,
    required this.tutorUserId,
    required this.tutorName,
    this.tutorImage,
    required this.courseName,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? 0,
      roomId: json['roomId'] ?? '',
      connectionId: json['connectionId'] ?? 0,
      studentId: json['studentId'] ?? 0,
      studentUserId: json['studentUserId'] ?? 0,
      studentName: json['studentName'] ?? '',
      studentImage: json['studentImage'],
      tutorId: json['tutorId'] ?? 0,
      tutorUserId: json['tutorUserId'] ?? 0,
      tutorName: json['tutorName'] ?? '',
      tutorImage: json['tutorImage'],
      courseName: json['courseName'] ?? '',
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null ? DateTime.parse(json['lastMessageAt']) : null,
      unreadCount: json['unreadCount'] ?? 0,
      isActive: json['active'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Message {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String senderName;
  final String? senderImage;
  final int recipientId;
  final String content;
  final String messageType;
  final DateTime sentAt;
  final bool isRead;
  bool isOwn;
  final String? audioUrl;
  final int? audioDuration;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileType;

  Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.recipientId,
    required this.content,
    this.messageType = 'TEXT',
    required this.sentAt,
    this.isRead = false,
    this.isOwn = false,
    this.audioUrl,
    this.audioDuration,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileType,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      chatRoomId: json['chatRoomId'] ?? 0,
      senderId: json['senderId'] ?? 0,
      senderName: json['senderName'] ?? '',
      senderImage: json['senderImage'],
      recipientId: json['recipientId'] ?? 0,
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'TEXT',
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : DateTime.now(),
      isRead: json['read'] ?? false,
      isOwn: json['own'] ?? false,
      audioUrl: json['audioUrl'],
      audioDuration: json['audioDuration'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      fileType: json['fileType'],
    );
  }
}

class SendMessageRequest {
  final int chatRoomId;
  final int senderId;
  final int recipientId;
  final String content;
  final String? audioUrl;
  final int? audioDuration;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? fileType;

  SendMessageRequest({
    required this.chatRoomId,
    required this.senderId,
    required this.recipientId,
    required this.content,
    this.audioUrl,
    this.audioDuration,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileType,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      if (audioUrl != null) 'audioUrl': audioUrl,
      if (audioDuration != null) 'audioDuration': audioDuration,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (fileName != null) 'fileName': fileName,
      if (fileSize != null) 'fileSize': fileSize,
      if (fileType != null) 'fileType': fileType,
    };
  }
}