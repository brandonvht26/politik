import 'package:dart_appwrite/dart_appwrite.dart';

void main() async {
  final client = Client()
      .setEndpoint('https://nyc.cloud.appwrite.io/v1')
      .setProject('6a3d9de20033b2990675')
      .setKey('standard_1d52f82a78182ac5aa48f1af9772ac37bc0e89d31d8926dbf0b2509ef8a54b95507787f570a1d2db42d235203d2e907c68d52d78a439c7129f8d8e34e75ec05ff14e5698ad414e11504cb3e29b79a6e212f93aa1e8f4474b3d9d57f5edea4e2138a20e45a899e3faa43dbe34a4a79b21748902aae367678ee3cdc181e6310cc1');

  final databases = Databases(client);

  try {
    final collection = await databases.getCollection(
      databaseId: '6a3decd900273fcbae5e',
      collectionId: 'actas',
    );
    print('Attributes of ACTAS collection:');
    for (final attr in collection.attributes) {
      print('- ${attr['key']} (${attr['type']})');
    }
  } catch (e) {
    print('Error: $e');
  }
}
