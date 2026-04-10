import 'package:equatable/equatable.dart';

import '../../../chat/data/models/chat_session.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.sessions = const [],
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<ChatSession> sessions;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<ChatSession>? sessions,
    String? errorMessage,
  }) {
    return HistoryState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, sessions, errorMessage];
}
