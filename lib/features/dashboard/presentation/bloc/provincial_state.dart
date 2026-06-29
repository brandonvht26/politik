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
  final List<Map<String, dynamic>> actas;
  final List<Map<String, dynamic>> organizacionesPoliticas;
  final List<Map<String, dynamic>> parroquias;

  const ProvincialDataLoaded({
    required this.recintos,
    required this.coordinadores,
    required this.actas,
    required this.organizacionesPoliticas,
    required this.parroquias,
  });

  @override
  List<Object?> get props => [recintos, coordinadores, actas, organizacionesPoliticas, parroquias];
}

class ProvincialActionSuccess extends ProvincialState {
  final String message;

  const ProvincialActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProvincialActionError extends ProvincialState {
  final String message;

  const ProvincialActionError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProvincialError extends ProvincialState {
  final String message;

  const ProvincialError(this.message);

  @override
  List<Object?> get props => [message];
}
