import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/acta_escrutinio_local_entity.dart';
import '../../domain/usecases/capture_photo.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/save_acta_local.dart';
import 'acta_event.dart';
import 'acta_state.dart';

class ActaBloc extends Bloc<ActaEvent, ActaState> {
  final CapturePhoto _capturePhoto;
  final GetCurrentLocation _getCurrentLocation;
  final SaveActaLocal _saveActaLocal;

  ActaBloc({
    required CapturePhoto capturePhoto,
    required GetCurrentLocation getCurrentLocation,
    required SaveActaLocal saveActaLocal,
  })  : _capturePhoto = capturePhoto,
        _getCurrentLocation = getCurrentLocation,
        _saveActaLocal = saveActaLocal,
        super(ActaInitial()) {
    on<CapturePhotoRequested>(_onCapturePhoto);
    on<SaveActaRequested>(_onSaveActa);
  }

  Future<void> _onCapturePhoto(
    CapturePhotoRequested event,
    Emitter<ActaState> emit,
  ) async {
    emit(ActaLoading());
    try {
      final path = await _capturePhoto();
      emit(ActaPhotoCaptured(path));
    } catch (e) {
      emit(ActaError(e.toString()));
    }
  }

  Future<void> _onSaveActa(
    SaveActaRequested event,
    Emitter<ActaState> emit,
  ) async {
    final sumaVotos = event.votosPartidos.fold<int>(
          0,
          (sum, v) => sum + v.cantidadVotos,
        ) +
        event.votosBlancos +
        event.votosNulos;

    if (sumaVotos > event.totalSufragantes) {
      emit(ActaValidationError(
        'La suma de votos ($sumaVotos) excede el total de sufragantes (${event.totalSufragantes}).',
      ));
      return;
    }

    emit(ActaLoading());

    try {
      final location = await _getCurrentLocation();
      final uuid =
          '${event.recintoId}_${event.mesaId}_${event.tipo}_${DateTime.now().millisecondsSinceEpoch}';

      final acta = ActaEscrutinioLocalEntity(
        uuid: uuid,
        recintoId: event.recintoId,
        mesaId: event.mesaId,
        tipo: event.tipo,
        votosPartidos: event.votosPartidos,
        votosBlancos: event.votosBlancos,
        votosNulos: event.votosNulos,
        totalSufragantes: event.totalSufragantes,
        latitud: location.latitude,
        longitud: location.longitude,
        imageLocalPath: event.imageLocalPath,
        isSynced: false,
        createdAt: DateTime.now(),
      );

      await _saveActaLocal(acta);
      emit(ActaSuccess());
    } catch (e) {
      emit(ActaError(e.toString()));
    }
  }
}
