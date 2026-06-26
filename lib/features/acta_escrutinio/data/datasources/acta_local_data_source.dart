import 'package:hive/hive.dart';

import '../../../../core/services/local_storage_service.dart';
import '../models/acta_escrutinio_local_model.dart';

abstract class ActaLocalDataSource {
  Future<void> saveActa(ActaEscrutinioLocalModel acta);
  Future<List<ActaEscrutinioLocalModel>> getPendingActas();
  Future<void> updateActaSyncStatus(String uuid, bool status);
}

class ActaLocalDataSourceImpl implements ActaLocalDataSource {
  final Box<ActaEscrutinioLocalModel> _actasBox;

  ActaLocalDataSourceImpl({Box<ActaEscrutinioLocalModel>? actasBox})
      : _actasBox = actasBox ?? LocalStorageService.actasLocalesBox;

  @override
  Future<void> saveActa(ActaEscrutinioLocalModel acta) async {
    await _actasBox.put(acta.uuid, acta);
  }

  @override
  Future<List<ActaEscrutinioLocalModel>> getPendingActas() async {
    return _actasBox.values.where((acta) => !acta.isSynced).toList();
  }

  @override
  Future<void> updateActaSyncStatus(String uuid, bool status) async {
    final acta = _actasBox.get(uuid);
    if (acta != null) {
      final updated = ActaEscrutinioLocalModel(
        uuid: acta.uuid,
        recintoId: acta.recintoId,
        mesaId: acta.mesaId,
        tipo: acta.tipo,
        votosPartidos: acta.votosPartidos,
        votosBlancos: acta.votosBlancos,
        votosNulos: acta.votosNulos,
        totalSufragantes: acta.totalSufragantes,
        latitud: acta.latitud,
        longitud: acta.longitud,
        imageLocalPath: acta.imageLocalPath,
        imageId: acta.imageId,
        isSynced: status,
        createdAt: acta.createdAt,
      );
      await _actasBox.put(uuid, updated);
    }
  }
}
