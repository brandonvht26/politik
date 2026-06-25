import 'package:hive/hive.dart';

import '../models/acta_escrutinio_model.dart';

abstract class ActaLocalDataSource {
  Future<void> saveActa(ActaEscrutinioModel acta);
  Future<List<ActaEscrutinioModel>> getPendingActas();
  Future<void> updateActaSyncStatus(String id, bool status);
}

class ActaLocalDataSourceImpl implements ActaLocalDataSource {
  final Box<ActaEscrutinioModel> _actasBox;

  ActaLocalDataSourceImpl({Box<ActaEscrutinioModel>? actasBox})
      : _actasBox = actasBox ?? Hive.box<ActaEscrutinioModel>('actas');

  @override
  Future<void> saveActa(ActaEscrutinioModel acta) async {
    await _actasBox.put(acta.id, acta);
  }

  @override
  Future<List<ActaEscrutinioModel>> getPendingActas() async {
    return _actasBox.values.where((acta) => !acta.isSynced).toList();
  }

  @override
  Future<void> updateActaSyncStatus(String id, bool status) async {
    final acta = _actasBox.get(id);
    if (acta != null) {
      final updated = ActaEscrutinioModel(
        id: acta.id,
        idJrv: acta.idJrv,
        dignidad: acta.dignidad,
        votosPorPartido: acta.votosPorPartido,
        votosBlancos: acta.votosBlancos,
        votosNulos: acta.votosNulos,
        totalSufragantes: acta.totalSufragantes,
        latitud: acta.latitud,
        longitud: acta.longitud,
        imagePath: acta.imagePath,
        isSynced: status,
      );
      await _actasBox.put(id, updated);
    }
  }
}
