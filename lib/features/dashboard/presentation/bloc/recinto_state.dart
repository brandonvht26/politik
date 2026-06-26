import 'package:equatable/equatable.dart';

import '../../domain/entities/recinto_entity.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class RecintoState extends Equatable {
  const RecintoState();

  @override
  List<Object?> get props => [];
}

class RecintoInitial extends RecintoState {}

class RecintoLoading extends RecintoState {}

class RecintoDataLoaded extends RecintoState {
  final RecintoEntity recinto;
  final List<UserProfileEntity> veedores;

  const RecintoDataLoaded({
    required this.recinto,
    required this.veedores,
  });

  @override
  List<Object?> get props => [recinto, veedores];
}

class RecintoActionSuccess extends RecintoState {
  final String message;

  const RecintoActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class RecintoError extends RecintoState {
  final String message;

  const RecintoError(this.message);

  @override
  List<Object?> get props => [message];
}
