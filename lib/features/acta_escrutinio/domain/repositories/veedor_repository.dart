import '../entities/acta_escrutinio_local_entity.dart';
import '../entities/location_entity.dart';

/// Repository contract for the veedor flow (Fase 4).
///
/// All operations are local/offline: photo capture + blur validation,
/// GPS acquisition and Hive persistence of the acta.
abstract class VeedorRepository {
  /// Opens the camera, validates that the image is sharp and returns the
  /// local file path. Throws if the photo is blurry or capture fails.
  Future<String> captureAndValidatePhoto();

  /// Obtains the current GPS position. Throws if permissions are denied.
  Future<LocationEntity> getCurrentLocation();

  /// Persists the acta in the local Hive box `actas_locales` with
  /// `isSynced = false`.
  Future<void> saveActaLocal(ActaEscrutinioLocalEntity acta);
}
