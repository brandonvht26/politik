import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../../features/acta_escrutinio/data/models/acta_escrutinio_local_model.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import 'appwrite_service.dart';

/// Background synchronization service for the Offline-First strategy.
///
/// It listens to network connectivity changes and to the authentication
/// state. When the device is online and a user is authenticated, it uploads
/// pending actas from the `actas_locales` Hive box to Appwrite:
///
/// 1. Uploads the image to the `actas_images` Storage bucket.
/// 2. Creates a document in the `actas` collection with the votes and GPS.
/// 3. Marks the local Hive record as `isSynced = true` only after both
///    remote operations succeed.
class SyncService {
  final AppwriteService _appwrite;
  final Box<ActaEscrutinioLocalModel> _actasBox;
  final AuthBloc _authBloc;

  bool _isAuthenticated = false;
  bool _hasConnection = false;
  bool _isSyncing = false;

  SyncService({
    required AppwriteService appwriteService,
    required Box<ActaEscrutinioLocalModel> actasBox,
    required AuthBloc authBloc,
  })  : _appwrite = appwriteService,
        _actasBox = actasBox,
        _authBloc = authBloc;

  /// Starts listening to connectivity and authentication events.
  Future<void> initialize() async {
    final initialResults = await Connectivity().checkConnectivity();
    _hasConnection = initialResults.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
    _listenToConnectivity();
    _listenToAuthState();
    _trySync();
  }

  void _listenToConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      _hasConnection = results.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );
      _trySync();
    });
  }

  void _listenToAuthState() {
    _authBloc.stream.listen((state) {
      _isAuthenticated = state is AuthSuccess;
      _trySync();
    });
  }

  void _trySync() {
    if (!_hasConnection || !_isAuthenticated || _isSyncing) return;

    _syncPendingActas();
  }

  Future<void> _syncPendingActas() async {
    _isSyncing = true;

    try {
      final pending =
          _actasBox.values.where((acta) => !acta.isSynced).toList();

      for (final acta in pending) {
        await _syncActa(acta);
      }
    } catch (e) {
      debugPrint('Error general en sincronización: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncActa(ActaEscrutinioLocalModel acta) async {
    try {
      debugPrint('Sincronizando acta ${acta.uuid}...');

      // 1. Upload the image to Appwrite Storage.
      final uploadedFile = await _appwrite.storage.createFile(
        bucketId: _appwrite.storageBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: acta.imageLocalPath),
      );

      final imageId = uploadedFile.$id;

      // 2. Serialize votes to JSON as defined in database.md.
      final votosMap = <String, int>{};
      for (final voto in acta.votosPartidos) {
        votosMap[voto.nombreOrganizacion] = voto.cantidadVotos;
      }

      final existingDocs = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.actasCollectionId,
        queries: [
          Query.equal('recinto_id', acta.recintoId),
          Query.equal('id_jrv', acta.mesaId),
          Query.equal('dignidad', acta.tipo),
        ],
      );

      final dataPayload = {
        'recinto_id': acta.recintoId,
        'id_jrv': acta.mesaId,
        'dignidad': acta.tipo,
        'votos_partidos': jsonEncode(votosMap),
        'votos_blancos': acta.votosBlancos,
        'votos_nulos': acta.votosNulos,
        'total_sufragantes': acta.totalSufragantes,
        'latitud': acta.latitud,
        'longitud': acta.longitud,
        'image_id': imageId,
      };

      if (existingDocs.documents.isNotEmpty) {
        await _appwrite.databases.updateDocument(
          databaseId: _appwrite.databaseId,
          collectionId: _appwrite.actasCollectionId,
          documentId: existingDocs.documents.first.$id,
          data: dataPayload,
        );
      } else {
        await _appwrite.databases.createDocument(
          databaseId: _appwrite.databaseId,
          collectionId: _appwrite.actasCollectionId,
          documentId: ID.unique(),
          data: dataPayload,
        );
      }

      // 4. Mark local record as synced ONLY after remote success.
      final syncedActa = ActaEscrutinioLocalModel(
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
        imageId: imageId,
        isSynced: true,
        createdAt: acta.createdAt,
      );

      await _actasBox.put(acta.uuid, syncedActa);
      debugPrint('Acta ${acta.uuid} sincronizada exitosamente.');
    } catch (e) {
      debugPrint('Error sincronizando acta ${acta.uuid}: $e');
      // Leave isSynced = false; retry on next trigger.
    }
  }
}
