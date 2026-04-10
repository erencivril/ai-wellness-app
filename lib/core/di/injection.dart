import 'package:get_it/get_it.dart';

import '../services/firebase_ai_service.dart';
import '../services/remote_config_service.dart';
import '../../features/chat/data/repositories/chat_repository.dart';
import '../../features/coaches/data/repositories/coach_repository.dart';
import '../../features/history/data/repositories/history_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  final remoteConfig = await RemoteConfigService.init();
  getIt.registerSingleton<RemoteConfigService>(remoteConfig);

  getIt.registerLazySingleton<FirebaseAIService>(() => FirebaseAIService());
  getIt.registerLazySingleton<CoachRepository>(
    () => CoachRepository(getIt<RemoteConfigService>()),
  );
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepository());
  getIt.registerLazySingleton<HistoryRepository>(() => HistoryRepository());
}
