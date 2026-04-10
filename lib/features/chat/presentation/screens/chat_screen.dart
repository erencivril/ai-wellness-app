import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, this.coachId, this.sessionId})
      : assert(
          coachId != null || sessionId != null,
          'Either coachId or sessionId must be provided',
        );

  final String? coachId;
  final String? sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(child: Text('Chat')),
    );
  }
}
