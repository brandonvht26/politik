import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/acta_local_data_source.dart';
import '../../data/models/acta_escrutinio_model.dart';
import 'acta_event.dart';
import 'acta_state.dart';

class ActaBloc extends Bloc<ActaEvent, ActaState> {
  final ActaLocalDataSource localDataSource;

  ActaBloc({required this.localDataSource}) : super(ActaInitial()) {
    on<SaveActaEvent>(_onSaveActa);
  }

  Future<void> _onSaveActa(
    SaveActaEvent event,
    Emitter<ActaState> emit,
  ) async {
    emit(ActaLoading());
    try {
      final model = ActaEscrutinioModel.fromEntity(event.acta);
      await localDataSource.saveActa(model);
      emit(ActaSuccess());
    } catch (e) {
      emit(ActaError(e.toString()));
    }
  }
}
