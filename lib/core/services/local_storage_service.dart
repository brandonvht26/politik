import 'package:hive_flutter/hive_flutter.dart';

import '../../features/acta_escrutinio/data/models/acta_escrutinio_model.dart';
import '../../features/acta_escrutinio/data/models/votos_partido_model.dart';

class LocalStorageService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(VotosPartidoModelAdapter());
    Hive.registerAdapter(ActaEscrutinioModelAdapter());
    await Hive.openBox<ActaEscrutinioModel>('actas');
  }
}
