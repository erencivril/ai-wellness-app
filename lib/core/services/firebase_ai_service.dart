import 'package:firebase_ai/firebase_ai.dart';

import '../../features/chat/data/models/chat_message.dart';

class FirebaseAIService {
  GenerativeModel _createModel(String systemInstruction) {
    return FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(systemInstruction),
    );
  }

  ChatSession startNewChat(String systemInstruction) {
    final model = _createModel(systemInstruction);
    return model.startChat();
  }

  ChatSession resumeChat(
    String systemInstruction,
    List<ChatMessage> history,
  ) {
    final model = _createModel(systemInstruction);
    final contents = _toContents(history);
    return model.startChat(history: contents);
  }

  Stream<String> sendMessageStream(ChatSession chat, String text) async* {
    final stream = chat.sendMessageStream(Content.text(text));
    await for (final chunk in stream) {
      final chunkText = chunk.text;
      if (chunkText != null && chunkText.isNotEmpty) {
        yield chunkText;
      }
    }
  }

  List<Content> _toContents(List<ChatMessage> messages) {
    return messages.map((m) {
      if (m.role == MessageRole.user) {
        return Content.text(m.text);
      } else {
        return Content.model([TextPart(m.text)]);
      }
    }).toList();
  }
}
