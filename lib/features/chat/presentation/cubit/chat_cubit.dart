import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart' as firebase_ai;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/firebase_ai_service.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/chat_session.dart';
import '../../data/repositories/chat_repository.dart';
import '../../../coaches/data/models/coach.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.coach,
    required this.chatRepository,
    required this.aiService,
    this.existingSessionId,
  }) : super(const ChatState());

  final Coach coach;
  final ChatRepository chatRepository;
  final FirebaseAIService aiService;
  final String? existingSessionId;

  firebase_ai.ChatSession? _chatSession;
  StreamSubscription<String>? _streamSub;

  Future<void> initChat() async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      if (existingSessionId != null) {
        await _resumeExistingChat(existingSessionId!);
      } else {
        await _startNewChat();
      }
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _startNewChat() async {
    final session = ChatSession(
      id: const Uuid().v4(),
      coachId: coach.id,
      coachName: coach.name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await chatRepository.createSession(session);
    _chatSession = aiService.startNewChat(coach.systemInstruction);
    emit(state.copyWith(status: ChatStatus.ready, session: session));
  }

  Future<void> _resumeExistingChat(String sessionId) async {
    final session = await chatRepository.getSession(sessionId);
    if (session == null) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'Session not found',
      ));
      return;
    }
    final messages = await chatRepository.getMessages(sessionId);
    _chatSession = aiService.resumeChat(coach.systemInstruction, messages);
    emit(state.copyWith(
      status: ChatStatus.ready,
      session: session,
      messages: messages,
    ));
  }

  Future<void> sendMessage(String text) async {
    if (_chatSession == null || state.session == null) return;
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      sessionId: state.session!.id,
      role: MessageRole.user,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    await chatRepository.insertMessage(userMessage);
    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      status: ChatStatus.streaming,
      streamingText: '',
    ));

    final buffer = StringBuffer();

    _streamSub = aiService
        .sendMessageStream(_chatSession!, text.trim())
        .listen(
      (chunk) {
        buffer.write(chunk);
        emit(state.copyWith(streamingText: buffer.toString()));
      },
      onDone: () async {
        final fullText = buffer.toString();
        final aiMessage = ChatMessage(
          sessionId: state.session!.id,
          role: MessageRole.model,
          text: fullText,
          timestamp: DateTime.now(),
        );
        await chatRepository.insertMessage(aiMessage);
        final updatedSession = state.session!.copyWith(
          updatedAt: DateTime.now(),
          lastMessage: fullText.length > 80
              ? '${fullText.substring(0, 80)}...'
              : fullText,
        );
        await chatRepository.updateSession(updatedSession);
        emit(state.copyWith(
          messages: [...state.messages, aiMessage],
          status: ChatStatus.ready,
          streamingText: '',
          session: updatedSession,
        ));
      },
      onError: (e) {
        emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: e.toString(),
          streamingText: '',
        ));
      },
    );
  }

  @override
  Future<void> close() async {
    await _streamSub?.cancel();
    return super.close();
  }
}
