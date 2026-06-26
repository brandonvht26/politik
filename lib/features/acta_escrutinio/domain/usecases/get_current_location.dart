import '../entities/location_entity.dart';
import '../repositories/veedor_repository.dart';

class GetCurrentLocation {
  final VeedorRepository _repository;

  const GetCurrentLocation(this._repository);

  Future<LocationEntity> call() => _repository.getCurrentLocation();
}
