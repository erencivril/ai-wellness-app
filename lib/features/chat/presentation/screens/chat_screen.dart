import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/firebase_ai_service.dart';
import '../../../coaches/data/models/coach.dart';
import '../../data/repositories/chat_repository.dart';
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
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Column(
        children: [
          _ChatAppBar(topPadding: top, coachName: widget.coachName),
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listenWhen: (prev, curr) =>
                  prev.messages.length != curr.messages.length ||
                  prev.streamingText != curr.streamingText ||
                  (curr.status == ChatStatus.error &&
                      prev.status != ChatStatus.error &&
                      prev.messages.isNotEmpty),
              listener: (context, state) {
                _scrollToBottom();
                if (state.status == ChatStatus.error &&
                    state.messages.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage ?? 'Failed to send message',
                      ),
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
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  );
                }

                if (state.status == ChatStatus.error &&
                    state.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        state.errorMessage ?? 'Something went wrong',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(color: AppColors.creamMuted),
                      ),
                    ),
                  );
                }

                final isStreaming = state.status == ChatStatus.streaming;

                if (state.messages.isEmpty && !isStreaming) {
                  return _EmptyChat(
                    coachName:
                        state.session?.coachName ?? widget.coachName,
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                onSend: context.read<ChatCubit>().sendMessage,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({required this.topPadding, required this.coachName});
  final double topPadding;
  final String coachName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, topPadding + 8, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: AppColors.cream),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (prev, curr) => prev.session != curr.session,
            builder: (context, state) {
              final name = state.session?.coachName ?? coachName;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: AppColors.cream,
                    ),
                  ),
                  Text(
                    'AI Coach',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.sageDim,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sage,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.coachName});
  final String coachName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceRaised,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.sageDim,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Begin your session',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your $coachName is ready to help. Ask anything.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.creamMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
