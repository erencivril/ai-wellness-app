import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/history_repository.dart';
import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._repository) : super(const HistoryState());

  final HistoryRepository _repository;

  Future<void> loadHistory() async {
    emit(state.copyWith(status: HistoryStatus.loading));
    try {
      final sessions = await _repository.getAllSessions();
      emit(state.copyWith(status: HistoryStatus.loaded, sessions: sessions));
    } catch (e) {
      emit(state.copyWith(
        status: HistoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
