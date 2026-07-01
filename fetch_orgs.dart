import 'package:dart_appwrite/dart_appwrite.dart';

void main() async {
  final client = Client()
    .setEndpoint('https://nyc.cloud.appwrite.io/v1')
    .setProject('6a3d9de20033b2990675');

  final db = Databases(client);

  try {
    final res = await db.listDocuments(
      databaseId: '6a3decd900273fcbae5e',
      collectionId: 'organizaciones_politicas',
    );
    for (var doc in res.documents) {
      print(doc.data);
    }
  } catch (e) {
    print('Error: $e');
  }
}
