import 'package:hive/hive.dart';

import '../../domain/entities/session_entity.dart';

part 'session_model.g.dart';

/// Hive model for the `session` box.
@HiveType(typeId: 5)
class SessionModel extends SessionEntity {
  @override
  @HiveField(0)
  String get cedula => super.cedula;

  @override
  @HiveField(1)
  String get rol => super.rol;

  @override
  @HiveField(2)
  String? get recintoId => super.recintoId;

  const SessionModel({
    required super.cedula,
    required super.rol,
    super.recintoId,
  });

  factory SessionModel.fromEntity(SessionEntity entity) {
    return SessionModel(
      cedula: entity.cedula,
      rol: entity.rol,
      recintoId: entity.recintoId,
    );
  }

  SessionEntity toEntity() {
    return SessionEntity(
      cedula: cedula,
      rol: rol,
      recintoId: recintoId,
    );
  }
}
