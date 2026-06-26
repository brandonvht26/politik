import '../entities/user_entity.dart';

/// Authentication contract for the app.
///
/// The implementation hides the Appwrite email mapping (`[cedula]@politik.com`)
/// and the local Hive session persistence from the rest of the app.
abstract class AuthRepository {
  /// Logs in with the national ID ([cedula]) and [password].
  ///
  /// Internally maps [cedula] to `[cedula]@politik.com`, fetches the user
  /// profile from Appwrite, caches the session in Hive and returns the
  /// authenticated [UserEntity].
  Future<UserEntity> login({
    required String cedula,
    required String password,
  });

  /// Updates the current user's password in Appwrite.
  ///
  /// Requires an active session. Returns the updated [UserEntity].
  Future<UserEntity> changePassword({required String newPassword});

  /// Ends the Appwrite session and clears the local Hive session.
  Future<void> logout();
}
