import 'package:equatable/equatable.dart';

import '../../domain/entities/acta_escrutinio_entity.dart';

abstract class ActaEvent extends Equatable {
  const ActaEvent();

  @override
  List<Object?> get props => [];
}

class SaveActaEvent extends ActaEvent {
  final ActaEscrutinioEntity acta;

  const SaveActaEvent({required this.acta});

  @override
  List<Object?> get props => [acta];
}
