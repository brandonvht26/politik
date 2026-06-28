import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recinto_entity.dart';
import '../../domain/entities/user_profile_entity.dart';

import '../../domain/usecases/create_coordinador_recinto.dart';
import '../../domain/usecases/create_recinto.dart';
import '../../domain/usecases/get_coordinadores_recinto.dart';
import '../../domain/usecases/get_recintos.dart';
import '../../domain/usecases/get_actas.dart';
import '../../domain/usecases/get_organizaciones_politicas.dart';
import '../../domain/usecases/get_parroquias.dart';
import 'provincial_event.dart';
import 'provincial_state.dart';

class ProvincialBloc extends Bloc<ProvincialEvent, ProvincialState> {
  final GetRecintos _getRecintos;
  final GetCoordinadoresRecinto _getCoordinadores;
  final CreateRecinto _createRecinto;
  final CreateCoordinadorRecinto _createCoordinador;
  final GetActas _getActas;
  final GetOrganizacionesPoliticas _getOrganizacionesPoliticas;
  final GetParroquias _getParroquias;

  ProvincialBloc({
    required GetRecintos getRecintos,
    required GetCoordinadoresRecinto getCoordinadores,
    required CreateRecinto createRecinto,
    required CreateCoordinadorRecinto createCoordinador,
    required GetActas getActas,
    required GetOrganizacionesPoliticas getOrganizacionesPoliticas,
    required GetParroquias getParroquias,
  })  : _getRecintos = getRecintos,
        _getCoordinadores = getCoordinadores,
        _createRecinto = createRecinto,
        _createCoordinador = createCoordinador,
        _getActas = getActas,
        _getOrganizacionesPoliticas = getOrganizacionesPoliticas,
        _getParroquias = getParroquias,
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
      final results = await Future.wait([
        _getRecintos(),
        _getCoordinadores(),
        _getActas(),
        _getOrganizacionesPoliticas(),
        _getParroquias(),
      ]);

      emit(ProvincialDataLoaded(
        recintos: results[0] as List<RecintoEntity>,
        coordinadores: results[1] as List<UserProfileEntity>,
        actas: results[2] as List<Map<String, dynamic>>,
        organizacionesPoliticas: results[3] as List<Map<String, dynamic>>,
        parroquias: results[4] as List<Map<String, dynamic>>,
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
