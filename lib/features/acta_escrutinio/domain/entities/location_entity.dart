import 'package:equatable/equatable.dart';

/// GPS coordinates captured when registering an acta.
class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
