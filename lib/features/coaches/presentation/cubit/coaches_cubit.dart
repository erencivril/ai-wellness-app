import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/coach_repository.dart';
import 'coaches_state.dart';

class CoachesCubit extends Cubit<CoachesState> {
  CoachesCubit(this._repository) : super(const CoachesState());

  final CoachRepository _repository;

  Future<void> loadCoaches() async {
    emit(state.copyWith(status: CoachesStatus.loading));
    try {
      final coaches = _repository.loadCoaches();
      emit(state.copyWith(status: CoachesStatus.loaded, coaches: coaches));
    } catch (e) {
      emit(state.copyWith(
        status: CoachesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
