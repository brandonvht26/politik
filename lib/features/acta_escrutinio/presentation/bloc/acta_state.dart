import 'package:equatable/equatable.dart';

abstract class ActaState extends Equatable {
  const ActaState();

  @override
  List<Object?> get props => [];
}

class ActaInitial extends ActaState {}

class ActaLoading extends ActaState {}

class ActaSuccess extends ActaState {}

class ActaError extends ActaState {
  final String message;

  const ActaError(this.message);

  @override
  List<Object?> get props => [message];
}
