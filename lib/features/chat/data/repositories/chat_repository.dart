import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatRepository {
  Future<Database> get _db => AppDatabase.instance;

  Future<void> createSession(ChatSession session) async {
    final db = await _db;
    await db.insert('chat_sessions', session.toMap());
  }

  Future<ChatSession?> getSession(String id) async {
    final db = await _db;
    final rows = await db.query(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return ChatSession.fromMap(rows.first);
  }

  Future<List<ChatSession>> getAllSessions() async {
    final db = await _db;
    final rows = await db.query(
      'chat_sessions',
      orderBy: 'updated_at DESC',
    );
    return rows.map(ChatSession.fromMap).toList();
  }

  Future<void> updateSession(ChatSession session) async {
    final db = await _db;
    await db.update(
      'chat_sessions',
      {
        'updated_at': session.updatedAt.millisecondsSinceEpoch,
        'last_message': session.lastMessage,
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> deleteSession(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('messages', where: 'session_id = ?', whereArgs: [id]);
      await txn.delete('chat_sessions', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> insertMessage(ChatMessage message) async {
    final db = await _db;
    await db.insert('messages', message.toMap());
  }

  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final db = await _db;
    final rows = await db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return rows.map(ChatMessage.fromMap).toList();
  }
}
