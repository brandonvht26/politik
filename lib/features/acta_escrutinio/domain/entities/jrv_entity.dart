import 'package:equatable/equatable.dart';

class JrvEntity extends Equatable {
  final String id;
  final int numeroMesa;
  final String idRecinto;

  const JrvEntity({
    required this.id,
    required this.numeroMesa,
    required this.idRecinto,
  });

  @override
  List<Object?> get props => [id, numeroMesa, idRecinto];
}
