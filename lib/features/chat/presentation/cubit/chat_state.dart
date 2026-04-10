import 'package:equatable/equatable.dart';

import '../../data/models/chat_message.dart';
import '../../data/models/chat_session.dart';

enum ChatStatus { initial, loading, sending, streaming, ready, error }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.streamingText = '',
    this.session,
    this.errorMessage,
  });

  final ChatStatus status;
  final List<ChatMessage> messages;
  final String streamingText;
  final ChatSession? session;
  final String? errorMessage;

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    String? streamingText,
    ChatSession? session,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      streamingText: streamingText ?? this.streamingText,
      session: session ?? this.session,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, messages, streamingText, session, errorMessage];
}
