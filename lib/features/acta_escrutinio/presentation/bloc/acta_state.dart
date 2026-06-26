import 'package:equatable/equatable.dart';

abstract class ActaState extends Equatable {
  const ActaState();

  @override
  List<Object?> get props => [];
}

class ActaInitial extends ActaState {}

class ActaLoading extends ActaState {}

/// Emitted when a sharp photo has been captured.
class ActaPhotoCaptured extends ActaState {
  final String imagePath;

  const ActaPhotoCaptured(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

/// Emitted when the vote sum exceeds the total sufragantes.
class ActaValidationError extends ActaState {
  final String message;

  const ActaValidationError(this.message);

  @override
  List<Object?> get props => [message];
}

class ActaSuccess extends ActaState {}

class ActaError extends ActaState {
  final String message;

  const ActaError(this.message);

  @override
  List<Object?> get props => [message];
}
