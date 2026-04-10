import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../coaches/data/models/coach.dart';
import '../../data/repositories/chat_repository.dart';
import '../../../../core/services/firebase_ai_service.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/streaming_bubble.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, this.coach, this.sessionId})
      : assert(
          coach != null || sessionId != null,
          'Either coach or sessionId must be provided',
        );

  final Coach? coach;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(
        coach: coach ??
            const Coach(
              id: '',
              name: '',
              description: '',
              icon: Icons.person,
              remoteConfigKey: '',
            ),
        chatRepository: getIt<ChatRepository>(),
        aiService: getIt<FirebaseAIService>(),
        existingSessionId: sessionId,
      )..initChat(),
      child: _ChatView(coachName: coach?.name ?? ''),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({required this.coachName});

  final String coachName;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (prev, curr) => prev.session != curr.session,
          builder: (context, state) {
            return Text(state.session?.coachName ?? widget.coachName);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listenWhen: (prev, curr) =>
                  prev.messages.length != curr.messages.length ||
                  prev.streamingText != curr.streamingText ||
                  (curr.status == ChatStatus.error && prev.status != ChatStatus.error && prev.messages.isNotEmpty),
              listener: (context, state) {
                _scrollToBottom();
                if (state.status == ChatStatus.error && state.messages.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage ?? 'Failed to send message'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  prev.messages != curr.messages ||
                  prev.streamingText != curr.streamingText,
              builder: (context, state) {
                if (state.status == ChatStatus.loading ||
                    state.status == ChatStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ChatStatus.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.errorMessage ?? 'Something went wrong',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final isStreaming = state.status == ChatStatus.streaming;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: state.messages.length + (isStreaming ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isStreaming && index == state.messages.length) {
                      return StreamingBubble(text: state.streamingText);
                    }
                    return MessageBubble(message: state.messages[index]);
                  },
                );
              },
            ),
          ),
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (prev, curr) => prev.status != curr.status,
            builder: (context, state) {
              final isEnabled = state.status == ChatStatus.ready;
              return ChatInputBar(
                enabled: isEnabled,
                onSend: (text) => context.read<ChatCubit>().sendMessage(text),
              );
            },
          ),
        ],
      ),
    );
  }
}
