import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:dart_appwrite/dart_appwrite.dart' as server;

import '../../../../core/services/appwrite_service.dart';
import '../../domain/entities/recinto_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final AppwriteService _appwrite;

  DashboardRepositoryImpl({AppwriteService? appwriteService})
      : _appwrite = appwriteService ?? AppwriteService();

  void _ensureApiKey() {
    if (_appwrite.apiKey.isEmpty) {
      throw Exception(
        'APPWRITE_API_KEY no está configurado. Se requiere para crear usuarios jerárquicamente.',
      );
    }
  }

  @override
  Future<List<RecintoEntity>> getRecintos() async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.recintosCollectionId,
      );

      return response.documents.map(_mapRecintoDocument).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cargar recintos');
    }
  }

  @override
  Future<RecintoEntity> getRecinto(String recintoId) async {
    try {
      final document = await _appwrite.databases.getDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.recintosCollectionId,
        documentId: recintoId,
      );

      return _mapRecintoDocument(document);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cargar el recinto');
    }
  }

  @override
  Future<void> createRecinto(RecintoEntity recinto) async {
    try {
      await _appwrite.databases.createDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.recintosCollectionId,
        documentId: ID.unique(),
        data: {
          'canton': recinto.canton,
          'parroquia': recinto.parroquia,
          'nombre': recinto.nombre,
          'num_mesas': recinto.numMesas,
        },
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear el recinto');
    }
  }

  @override
  Future<List<UserProfileEntity>> getCoordinadoresRecinto() async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.profilesCollectionId,
        queries: [Query.equal('rol', 'recinto')],
      );

      return response.documents.map(_mapProfileDocument).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cargar coordinadores');
    }
  }

  @override
  Future<List<UserProfileEntity>> getVeedoresPorRecinto(String recintoId) async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.profilesCollectionId,
        queries: [
          Query.equal('recinto_id', recintoId),
          Query.equal('rol', 'veedor'),
        ],
      );

      return response.documents.map(_mapProfileDocument).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cargar veedores');
    }
  }

  @override
  Future<void> createCoordinadorRecinto({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correoReal,
    required String recintoId,
  }) async {
    _ensureApiKey();

    final nombreCompleto = '$nombres $apellidos';

    try {
      await _appwrite.users.create(
        userId: cedula,
        email: correoReal,
        password: 'Ecuador2026',
        name: nombreCompleto,
      );

      await _appwrite.databases.createDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.profilesCollectionId,
        documentId: cedula,
        data: {
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'correo_real': correoReal,
          'rol': 'recinto',
          'recinto_id': recintoId,
        },
      );
    } on server.AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear el coordinador de recinto');
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear el coordinador de recinto');
    }
  }

  @override
  Future<void> createVeedor({
    required String cedula,
    required String nombres,
    required String apellidos,
    required String telefono,
    required String correoReal,
    required String recintoId,
    required String mesaId,
  }) async {
    _ensureApiKey();

    final nombreCompleto = '$nombres $apellidos';

    try {
      await _appwrite.users.create(
        userId: cedula,
        email: correoReal,
        password: 'Ecuador2026',
        name: nombreCompleto,
      );

      await _appwrite.databases.createDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.profilesCollectionId,
        documentId: cedula,
        data: {
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'correo_real': correoReal,
          'rol': 'veedor',
          'recinto_id': recintoId,
          'mesa_id': mesaId,
        },
      );
    } on server.AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear el veedor');
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al crear el veedor');
    }
  }

  @override
  Future<void> reassignVeedorMesa({
    required String cedula,
    required String newMesaId,
  }) async {
    try {
      await _appwrite.databases.updateDocument(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.profilesCollectionId,
        documentId: cedula,
        data: {'mesa_id': newMesaId},
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al reasignar la mesa');
    }
  }

  RecintoEntity _mapRecintoDocument(Document doc) {
    return RecintoEntity(
      id: doc.$id,
      canton: doc.data['canton'] as String? ?? '',
      parroquia: doc.data['parroquia'] as String? ?? '',
      nombre: doc.data['nombre'] as String? ?? '',
      numMesas: (doc.data['num_mesas'] as num?)?.toInt() ?? 0,
    );
  }

  UserProfileEntity _mapProfileDocument(Document doc) {
    return UserProfileEntity(
      id: doc.$id,
      cedula: doc.data['cedula'] as String? ?? '',
      nombres: doc.data['nombres'] as String? ?? '',
      apellidos: doc.data['apellidos'] as String? ?? '',
      telefono: doc.data['telefono'] as String? ?? '',
      correoReal: doc.data['correo_real'] as String? ?? '',
      rol: doc.data['rol'] as String? ?? '',
      recintoId: doc.data['recinto_id'] as String?,
      mesaId: doc.data['mesa_id'] as String?,
    );
  }
}
