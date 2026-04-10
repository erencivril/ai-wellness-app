import 'package:equatable/equatable.dart';

import '../../data/models/coach.dart';

enum CoachesStatus { initial, loading, loaded, error }

class CoachesState extends Equatable {
  const CoachesState({
    this.status = CoachesStatus.initial,
    this.coaches = const [],
    this.errorMessage,
  });

  final CoachesStatus status;
  final List<Coach> coaches;
  final String? errorMessage;

  CoachesState copyWith({
    CoachesStatus? status,
    List<Coach>? coaches,
    String? errorMessage,
  }) {
    return CoachesState(
      status: status ?? this.status,
      coaches: coaches ?? this.coaches,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, coaches, errorMessage];
}
