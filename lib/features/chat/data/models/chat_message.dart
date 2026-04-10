enum MessageRole { user, model }

class ChatMessage {
  const ChatMessage({
    this.id,
    required this.sessionId,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  final int? id;
  final String sessionId;
  final MessageRole role;
  final String text;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'role': role.name,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      sessionId: map['session_id'] as String,
      role: MessageRole.values.byName(map['role'] as String),
      text: map['text'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
