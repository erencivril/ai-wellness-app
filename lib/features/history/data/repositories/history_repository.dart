import '../../../../core/database/app_database.dart';
import '../../../chat/data/models/chat_session.dart';

class HistoryRepository {
  Future<List<ChatSession>> getAllSessions() async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'chat_sessions',
      orderBy: 'updated_at DESC',
    );
    return rows.map(ChatSession.fromMap).toList();
  }
}
