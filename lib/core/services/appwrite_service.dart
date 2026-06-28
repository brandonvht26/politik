import 'package:appwrite/appwrite.dart';
import 'package:dart_appwrite/dart_appwrite.dart' as server;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  // Client SDK (used by the mobile app for Auth, Databases, Storage).
  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;

  // Server SDK (required for hierarchical user creation with an API key).
  late server.Client serverClient;
  late server.Users users;

  String get databaseId => dotenv.env['APPWRITE_DATABASE_ID'] ?? '';
  String get actasCollectionId => dotenv.env['APPWRITE_ACTAS_COLLECTION_ID'] ?? '';
  String get profilesCollectionId => dotenv.env['APPWRITE_PROFILES_COLLECTION_ID'] ?? '';
  String get recintosCollectionId => dotenv.env['APPWRITE_RECINTOS_COLLECTION_ID'] ?? '';
  String get organizacionesPoliticasCollectionId => dotenv.env['APPWRITE_ORGANIZACIONES_POLITICAS_COLLECTION_ID'] ?? '';
  String get parroquiasCollectionId => dotenv.env['APPWRITE_PARROQUIAS_COLLECTION_ID'] ?? '';
  String get storageBucketId => dotenv.env['APPWRITE_STORAGE_BUCKET_ID'] ?? '';
  String get apiKey => dotenv.env['APPWRITE_API_KEY'] ?? '';
  String get endpoint => dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
  String get projectId => dotenv.env['APPWRITE_PROJECT_ID'] ?? '';

  Future<void> init() async {
    final endpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
    final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';

    if (projectId.isEmpty) {
      throw Exception('APPWRITE_PROJECT_ID no está definido en el archivo .env');
    }

    // Client SDK initialization.
    client = Client()
        .setEndpoint(endpoint)
        .setProject(projectId)
        .setSelfSigned(status: true);

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);

    // Server SDK initialization (only needed for creating sub-users).
    serverClient = server.Client()
        .setEndpoint(endpoint)
        .setProject(projectId)
        .setSelfSigned(status: true);

    if (apiKey.isNotEmpty) {
      serverClient.setKey(apiKey);
    }

    users = server.Users(serverClient);
  }
}
