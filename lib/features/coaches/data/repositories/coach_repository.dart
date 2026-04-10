import 'package:flutter/material.dart';

import '../../../../core/services/remote_config_service.dart';
import '../models/coach.dart';

class CoachRepository {
  CoachRepository(this._remoteConfig);

  final RemoteConfigService _remoteConfig;

  static const _coaches = [
    Coach(
      id: 'dietitian',
      name: 'Dietitian',
      description: 'Evidence-based nutrition & meal planning',
      icon: Icons.restaurant_menu_outlined,
      remoteConfigKey: 'dietitian_system_instruction',
    ),
    Coach(
      id: 'fitness_coach',
      name: 'Fitness Coach',
      description: 'Personalized workouts & strength training',
      icon: Icons.fitness_center_outlined,
      remoteConfigKey: 'fitness_coach_system_instruction',
    ),
    Coach(
      id: 'pilates_instructor',
      name: 'Pilates Instructor',
      description: 'Core strength & mindful movement',
      icon: Icons.self_improvement_outlined,
      remoteConfigKey: 'pilates_instructor_system_instruction',
    ),
    Coach(
      id: 'yoga_teacher',
      name: 'Yoga Teacher',
      description: 'Yoga poses, breathwork & meditation',
      icon: Icons.spa_outlined,
      remoteConfigKey: 'yoga_teacher_system_instruction',
    ),
  ];

  List<Coach> loadCoaches() {
    return _coaches.map((coach) {
      final instruction = _remoteConfig.getString(coach.remoteConfigKey);
      return coach.copyWith(
        systemInstruction: instruction.isNotEmpty ? instruction : null,
      );
    }).toList();
  }
}
