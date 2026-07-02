import 'package:hive_flutter/hive_flutter.dart';

import '../../features/acta_escrutinio/data/models/acta_escrutinio_local_model.dart';
import '../../features/acta_escrutinio/data/models/acta_escrutinio_model.dart';
import '../../features/acta_escrutinio/data/models/voto_partido_local_model.dart';
import '../../features/acta_escrutinio/data/models/votos_partido_model.dart';
import '../../features/auth/data/models/session_model.dart';

/// Centralized Hive initialization and box management.
///
/// This service registers every Hive adapter used by the offline-first
/// features and opens the boxes declared in `.context/database.md`:
/// - `actas_locales`  -> local actas pending sync.
/// - `session`        -> cached logged-in user session.
///
/// The legacy `actas` box is also kept open to maintain compatibility with
/// the previous `ActaEscrutinioModel` data source.
class LocalStorageService {
  LocalStorageService._();

  static const String _actasLocalesBoxName = 'actas_locales';
  static const String _sessionBoxName = 'session';
  static const String _legacyActasBoxName = 'actas';
  static const String _organizacionesBoxName = 'organizaciones_politicas';

  static Box<ActaEscrutinioLocalModel>? _actasLocalesBox;
  static Box<SessionModel>? _sessionBox;
  static Box<ActaEscrutinioModel>? _legacyActasBox;
  static Box<String>? _organizacionesBox;

  /// Initializes Flutter Hive, registers all adapters and opens every box.
  ///
  /// Must be awaited before `runApp`.
  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
  }

  static void _registerAdapters() {
    // Legacy adapters (kept for backward compatibility).
    Hive.registerAdapter(VotosPartidoModelAdapter());
    Hive.registerAdapter(ActaEscrutinioModelAdapter());

    // Phase 1 adapters.
    Hive.registerAdapter(VotoPartidoLocalModelAdapter());
    Hive.registerAdapter(ActaEscrutinioLocalModelAdapter());
    Hive.registerAdapter(SessionModelAdapter());
  }

  static Future<void> _openBoxes() async {
    _actasLocalesBox =
        await Hive.openBox<ActaEscrutinioLocalModel>(_actasLocalesBoxName);
    _sessionBox = await Hive.openBox<SessionModel>(_sessionBoxName);
    _legacyActasBox =
        await Hive.openBox<ActaEscrutinioModel>(_legacyActasBoxName);
    _organizacionesBox = await Hive.openBox<String>(_organizacionesBoxName);
  }

  /// Box that stores local actas pending synchronization.
  static Box<ActaEscrutinioLocalModel> get actasLocalesBox {
    assert(
      _actasLocalesBox != null,
      'LocalStorageService has not been initialized. Call init() first.',
    );
    return _actasLocalesBox!;
  }

  /// Box that stores the cached user session.
  static Box<SessionModel> get sessionBox {
    assert(
      _sessionBox != null,
      'LocalStorageService has not been initialized. Call init() first.',
    );
    return _sessionBox!;
  }

  /// Legacy box used by the previous `ActaEscrutinioModel` implementation.
  static Box<ActaEscrutinioModel> get legacyActasBox {
    assert(
      _legacyActasBox != null,
      'LocalStorageService no inicializado. Llama a init() primero.',
    );
    return _legacyActasBox!;
  }

  /// Box that stores political organizations JSON caches.
  static Box<String> get organizacionesBox {
    assert(
      _organizacionesBox != null,
      'LocalStorageService no inicializado. Llama a init() primero.',
    );
    return _organizacionesBox!;
  }

  /// Closes all open boxes. Useful during integration testing teardown.
  static Future<void> dispose() async {
    await _actasLocalesBox?.close();
    await _sessionBox?.close();
    await _legacyActasBox?.close();
  }
}
