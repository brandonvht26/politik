import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_veedor.dart';
import '../../domain/usecases/get_recinto.dart';
import '../../domain/usecases/get_veedores_por_recinto.dart';
import '../../domain/usecases/reassign_veedor_mesa.dart';
import 'recinto_event.dart';
import 'recinto_state.dart';

class RecintoBloc extends Bloc<RecintoEvent, RecintoState> {
  final GetRecinto _getRecinto;
  final GetVeedoresPorRecinto _getVeedores;
  final CreateVeedor _createVeedor;
  final ReassignVeedorMesa _reassignVeedorMesa;

  String? _currentRecintoId;

  RecintoBloc({
    required GetRecinto getRecinto,
    required GetVeedoresPorRecinto getVeedores,
    required CreateVeedor createVeedor,
    required ReassignVeedorMesa reassignVeedorMesa,
  })  : _getRecinto = getRecinto,
        _getVeedores = getVeedores,
        _createVeedor = createVeedor,
        _reassignVeedorMesa = reassignVeedorMesa,
        super(RecintoInitial()) {
    on<LoadRecintoData>(_onLoadData);
    on<CreateVeedorRequested>(_onCreateVeedor);
    on<ReassignVeedorMesaRequested>(_onReassignMesa);
  }

  Future<void> _onLoadData(
    LoadRecintoData event,
    Emitter<RecintoState> emit,
  ) async {
    _currentRecintoId = event.recintoId;
    emit(RecintoLoading());

    try {
      final recinto = await _getRecinto(event.recintoId);
      final veedores = await _getVeedores(event.recintoId);
      emit(RecintoDataLoaded(recinto: recinto, veedores: veedores));
    } catch (e) {
      emit(RecintoError(e.toString()));
    }
  }

  Future<void> _onCreateVeedor(
    CreateVeedorRequested event,
    Emitter<RecintoState> emit,
  ) async {
    emit(RecintoLoading());

    try {
      await _createVeedor(
        cedula: event.cedula,
        nombres: event.nombres,
        apellidos: event.apellidos,
        telefono: event.telefono,
        correoReal: event.correoReal,
        recintoId: event.recintoId,
        mesaId: event.mesaId,
      );
      emit(const RecintoActionSuccess('Veedor creado exitosamente'));
      add(LoadRecintoData(event.recintoId));
    } catch (e) {
      emit(RecintoError(e.toString()));
    }
  }

  Future<void> _onReassignMesa(
    ReassignVeedorMesaRequested event,
    Emitter<RecintoState> emit,
  ) async {
    emit(RecintoLoading());

    try {
      await _reassignVeedorMesa(
        cedula: event.cedula,
        newMesaId: event.newMesaId,
      );
      emit(const RecintoActionSuccess('Mesa reasignada exitosamente'));
      if (_currentRecintoId != null) {
        add(LoadRecintoData(_currentRecintoId!));
      }
    } catch (e) {
      emit(RecintoError(e.toString()));
    }
  }
}
