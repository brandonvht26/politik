import 'dart:io';
import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
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
  Future<List<Map<String, dynamic>>> getActas() async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.actasCollectionId,
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cargar actas');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrganizacionesPoliticas() async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.organizacionesPoliticasCollectionId,
      );

      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cargar organizaciones políticas');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getParroquias() async {
    try {
      final response = await _appwrite.databases.listDocuments(
        databaseId: _appwrite.databaseId,
        collectionId: _appwrite.parroquiasCollectionId,
      );
      return response.documents.map((doc) => doc.data).toList();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Error al cargar parroquias');
    }
  }

  @override
  Stream<dynamic> subscribeToUpdates() {
    return _appwrite.realtime.subscribe([
      'databases.${_appwrite.databaseId}.collections.${_appwrite.actasCollectionId}.documents',
      'databases.${_appwrite.databaseId}.collections.${_appwrite.profilesCollectionId}.documents',
      'databases.${_appwrite.databaseId}.collections.${_appwrite.recintosCollectionId}.documents',
    ]).stream;
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
          'requires_password_change': true,
        },
      );

      // Enviar correo de verificación y asegurar que atrape cualquier error
      await _sendVerificationEmail(correoReal, 'Ecuador2026');
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
          'requires_password_change': true,
        },
      );

      // Enviar correo de verificación y asegurar que atrape cualquier error
      await _sendVerificationEmail(correoReal, 'Ecuador2026');
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

  /// Crea una sesión temporal del lado del cliente para disparar el correo de confirmación.
  /// Hack necesario porque el Server SDK (users.create) no dispara correos de verificación automáticos.
  Future<void> _sendVerificationEmail(String email, String password) async {
    try {
      // Usamos dart:io puro para AISLAR completamente la petición HTTP de las SharedPreferences 
      // del Flutter SDK. Así evitamos el error 401 "user_session_already_exists" y no destruimos
      // la sesión global de administrador.
      final endpoint = _appwrite.endpoint;
      final projectId = _appwrite.projectId;

      final httpClient = HttpClient();
      httpClient.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

      // 1. Iniciar sesión efímera usando REST puro
      final sessionUrl = Uri.parse('$endpoint/account/sessions/email');
      final sessionReq = await httpClient.postUrl(sessionUrl);
      sessionReq.headers.set('X-Appwrite-Project', projectId);
      sessionReq.headers.set('Content-Type', 'application/json');
      sessionReq.add(utf8.encode(jsonEncode({
        'email': email, 
        'password': password
      })));
      
      final sessionRes = await sessionReq.close();
      if (sessionRes.statusCode != 201) {
        throw Exception('Appwrite devolvió status ${sessionRes.statusCode} al crear sesión REST.');
      }

      // Extraer Cookie de la respuesta (Session Secret)
      final setCookie = sessionRes.headers['set-cookie'];
      String? fallbackCookie;
      if (setCookie != null && setCookie.isNotEmpty) {
        fallbackCookie = setCookie.join(';');
      }

      // 2. Solicitar verificación usando REST puro
      final verifyUrl = Uri.parse('$endpoint/account/verification');
      final verifyReq = await httpClient.postUrl(verifyUrl);
      verifyReq.headers.set('X-Appwrite-Project', projectId);
      verifyReq.headers.set('Content-Type', 'application/json');
      if (fallbackCookie != null) {
        verifyReq.headers.set('Cookie', fallbackCookie);
        verifyReq.headers.set('X-Fallback-Cookies', fallbackCookie);
      }
      
      // La auditoría recomendaba politik://verify pero Appwrite Cloud rechaza esquemas nativos.
      verifyReq.add(utf8.encode(jsonEncode({
        'url': 'https://politik-app.com/verify'
      })));
      
      final verifyRes = await verifyReq.close();
      if (verifyRes.statusCode != 201) {
        throw Exception('Appwrite devolvió status ${verifyRes.statusCode} al pedir verificación.');
      }

    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace, label: 'Fallo crítico al enviar correo de verificación');
      throw Exception('No se pudo enviar el correo de verificación. El usuario ha sido creado pero requiere verificación manual. Error: $e');
    }
  }
}
