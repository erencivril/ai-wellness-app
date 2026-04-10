class ChatSession {
  const ChatSession({
    required this.id,
    required this.coachId,
    required this.coachName,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  final String id;
  final String coachId;
  final String coachName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;

  ChatSession copyWith({
    DateTime? updatedAt,
    String? lastMessage,
  }) {
    return ChatSession(
      id: id,
      coachId: coachId,
      coachName: coachName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coach_id': coachId,
      'coach_name': coachName,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'last_message': lastMessage,
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'] as String,
      coachId: map['coach_id'] as String,
      coachName: map['coach_name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      lastMessage: map['last_message'] as String?,
    );
  }
}
