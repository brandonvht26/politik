import 'package:equatable/equatable.dart';

import '../../domain/entities/recinto_entity.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class ProvincialState extends Equatable {
  const ProvincialState();

  @override
  List<Object?> get props => [];
}

class ProvincialInitial extends ProvincialState {}

class ProvincialLoading extends ProvincialState {}

class ProvincialDataLoaded extends ProvincialState {
  final List<RecintoEntity> recintos;
  final List<UserProfileEntity> coordinadores;

  const ProvincialDataLoaded({
    required this.recintos,
    required this.coordinadores,
  });

  @override
  List<Object?> get props => [recintos, coordinadores];
}

class ProvincialActionSuccess extends ProvincialState {
  final String message;

  const ProvincialActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProvincialError extends ProvincialState {
  final String message;

  const ProvincialError(this.message);

  @override
  List<Object?> get props => [message];
}
