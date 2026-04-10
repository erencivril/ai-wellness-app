import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService._(this._config);

  final FirebaseRemoteConfig _config;

  static Future<RemoteConfigService> init() async {
    final config = FirebaseRemoteConfig.instance;

    await config.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 30),
      minimumFetchInterval: const Duration(hours: 1),
    ));

    await config.setDefaults({
      'dietitian_system_instruction':
          'You are a registered dietitian. Provide evidence-based nutritional advice. '
          'Be empathetic and practical. Always recommend consulting a doctor for medical conditions.',
      'fitness_coach_system_instruction':
          'You are a certified personal trainer and fitness coach. '
          'Help users with workout plans, exercise form, and motivation. '
          'Prioritize safety and proper technique above all else.',
      'pilates_instructor_system_instruction':
          'You are a certified Pilates instructor. Guide users through Pilates principles, '
          'exercises, and breathing techniques. Emphasize core strength and mindful movement.',
      'yoga_teacher_system_instruction':
          'You are an experienced yoga teacher. Share guidance on yoga poses, breathing, '
          'meditation, and the philosophy of yoga. Adapt advice to all levels of practitioners.',
    });

    try {
      await config.fetchAndActivate();
    } catch (_) {
      // Falls back to defaults if fetch fails
    }

    return RemoteConfigService._(config);
  }

  String getString(String key) => _config.getString(key);
}
