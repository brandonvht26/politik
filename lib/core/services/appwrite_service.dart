import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteService {
  // Instancia Singleton
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late Client client;
  late Account account;
  late Databases databases;
  late Storage storage;

  // Getters para acceso rápido a los IDs configurados en .env
  String get databaseId => dotenv.env['APPWRITE_DATABASE_ID'] ?? '';
  String get actasCollectionId => dotenv.env['APPWRITE_ACTAS_COLLECTION_ID'] ?? '';
  String get profilesCollectionId => dotenv.env['APPWRITE_PROFILES_COLLECTION_ID'] ?? '';
  String get recintosCollectionId => dotenv.env['APPWRITE_RECINTOS_COLLECTION_ID'] ?? '';
  String get storageBucketId => dotenv.env['APPWRITE_STORAGE_BUCKET_ID'] ?? '';

  Future<void> init() async {
    client = Client();

    final endpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://cloud.appwrite.io/v1';
    final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';

    if (projectId.isEmpty) {
      throw Exception('APPWRITE_PROJECT_ID no está definido en el archivo .env');
    }

    client
        .setEndpoint(endpoint)
        .setProject(projectId)
        .setSelfSigned(status: true); // Evita problemas de certificados SSL en desarrollo local

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }
}
