import '../../../../core/services/gps_service.dart';
import '../../../../core/services/image_capture_service.dart';
import '../../data/datasources/acta_local_data_source.dart';
import '../../data/models/acta_escrutinio_local_model.dart';
import '../../domain/entities/acta_escrutinio_local_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/veedor_repository.dart';

/// Offline-first implementation of [VeedorRepository].
///
/// It uses the device camera + blur detection, GPS and the local Hive box
/// `actas_locales`. No network calls are made here.
class VeedorRepositoryImpl implements VeedorRepository {
  final ActaLocalDataSource _localDataSource;

  VeedorRepositoryImpl({ActaLocalDataSource? localDataSource})
      : _localDataSource = localDataSource ?? ActaLocalDataSourceImpl();

  @override
  Future<String> captureAndValidatePhoto() {
    return ImageCaptureService.captureAndValidatePhoto();
  }

  @override
  Future<LocationEntity> getCurrentLocation() {
    return GpsService.getCurrentLocation();
  }

  @override
  Future<void> saveActaLocal(ActaEscrutinioLocalEntity acta) async {
    final model = ActaEscrutinioLocalModel.fromEntity(acta);
    await _localDataSource.saveActa(model);
  }
}
