import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskflow/core/constants/storage_keys.dart';
import 'package:taskflow/core/error/exceptions.dart';

abstract interface class AuthLocalDataSource {
  Future<bool> hasValidSession();
}

final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<bool> hasValidSession() async {
    try {
      final accessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      final expiresAtRaw = await _secureStorage.read(key: SecureStorageKeys.accessTokenExpiresAt);
      final expiresAt = expiresAtRaw != null ? DateTime.tryParse(expiresAtRaw) : null;
      if (expiresAt == null) {
        return true;
      }

      return DateTime.now().isBefore(expiresAt);
    } catch (_) {
      throw const CacheException('Unable to read the authentication session.');
    }
  }
}