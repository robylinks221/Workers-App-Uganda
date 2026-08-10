class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.otherUserName,
    required this.otherUserPhoto,
    required this.jobTitle,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  final int id;
  final String otherUserName;
  final String? otherUserPhoto;
  final String? jobTitle;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final other = _map(json['other_participant']);
    final job = _map(json['job']);

    return ChatConversation(
      id: _int(json['id']),
      otherUserName: _string(other['full_name']),
      otherUserPhoto: _nullable(other['profile_photo']),
      jobTitle: _nullable(job['title']),
      lastMessage: _nullable(json['last_message']),
      lastMessageAt: _date(json['last_message_at']),
      unreadCount: _int(json['unread_count']),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.isMine,
    required this.message,
    required this.isEdited,
    required this.readAt,
    required this.createdAt,
    this.senderName,
    this.senderPhoto,
  });

  final int id;
  final bool isMine;
  final String? message;
  final bool isEdited;
  final DateTime? readAt;
  final DateTime? createdAt;

  /// These remain optional so the current API stays compatible.
  /// When Laravel returns sender.full_name/profile_photo, both outgoing
  /// and incoming message bubbles show the correct profile image.
  final String? senderName;
  final String? senderPhoto;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final sender = _map(json['sender']);

    return ChatMessage(
      id: _int(json['id']),
      isMine: json['is_mine'] == true,
      message: _nullable(json['message']),
      isEdited: json['is_edited'] == true,
      readAt: _date(json['read_at']),
      createdAt: _date(json['created_at']),
      senderName:
          _nullable(sender['full_name']) ?? _nullable(json['sender_name']),
      senderPhoto:
          _nullable(sender['profile_photo']) ?? _nullable(json['sender_photo']),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _string(dynamic value) => value?.toString() ?? '';

String? _nullable(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(dynamic value) {
  final text = value?.toString() ?? '';
  return text.isEmpty ? null : DateTime.tryParse(text)?.toLocal();
}
