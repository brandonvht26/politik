import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_coordinador_recinto.dart';
import '../../domain/usecases/create_recinto.dart';
import '../../domain/usecases/get_coordinadores_recinto.dart';
import '../../domain/usecases/get_recintos.dart';
import 'provincial_event.dart';
import 'provincial_state.dart';

class ProvincialBloc extends Bloc<ProvincialEvent, ProvincialState> {
  final GetRecintos _getRecintos;
  final GetCoordinadoresRecinto _getCoordinadores;
  final CreateRecinto _createRecinto;
  final CreateCoordinadorRecinto _createCoordinador;

  ProvincialBloc({
    required GetRecintos getRecintos,
    required GetCoordinadoresRecinto getCoordinadores,
    required CreateRecinto createRecinto,
    required CreateCoordinadorRecinto createCoordinador,
  })  : _getRecintos = getRecintos,
        _getCoordinadores = getCoordinadores,
        _createRecinto = createRecinto,
        _createCoordinador = createCoordinador,
        super(ProvincialInitial()) {
    on<LoadProvincialData>(_onLoadData);
    on<CreateRecintoRequested>(_onCreateRecinto);
    on<CreateCoordinadorRecintoRequested>(_onCreateCoordinador);
  }

  Future<void> _onLoadData(
    LoadProvincialData event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(ProvincialLoading());

    try {
      final recintos = await _getRecintos();
      final coordinadores = await _getCoordinadores();
      emit(ProvincialDataLoaded(
        recintos: recintos,
        coordinadores: coordinadores,
      ));
    } catch (e) {
      emit(ProvincialError(e.toString()));
    }
  }

  Future<void> _onCreateRecinto(
    CreateRecintoRequested event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(ProvincialLoading());

    try {
      await _createRecinto(event.recinto);
      emit(const ProvincialActionSuccess('Recinto creado exitosamente'));
      add(LoadProvincialData());
    } catch (e) {
      emit(ProvincialError(e.toString()));
    }
  }

  Future<void> _onCreateCoordinador(
    CreateCoordinadorRecintoRequested event,
    Emitter<ProvincialState> emit,
  ) async {
    emit(ProvincialLoading());

    try {
      await _createCoordinador(
        cedula: event.cedula,
        nombres: event.nombres,
        apellidos: event.apellidos,
        telefono: event.telefono,
        correoReal: event.correoReal,
        recintoId: event.recintoId,
      );
      emit(const ProvincialActionSuccess(
        'Coordinador de recinto creado exitosamente',
      ));
      add(LoadProvincialData());
    } catch (e) {
      emit(ProvincialError(e.toString()));
    }
  }
}
