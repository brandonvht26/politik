import 'package:equatable/equatable.dart';

class RecintoEntity extends Equatable {
  final String id;
  final String canton;
  final String parroquia;
  final String nombre;
  final int numMesas;

  const RecintoEntity({
    required this.id,
    required this.canton,
    required this.parroquia,
    required this.nombre,
    required this.numMesas,
  });

  @override
  List<Object?> get props => [id, canton, parroquia, nombre, numMesas];
}
