import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/constants/storage_keys.dart';

abstract class CurrentSession {
  Future<String?> get currentOrgId;
  Future<String?> get currentUserId;
  Future<String?> get currentUserRole;
}

@LazySingleton(as: CurrentSession)
class CurrentSessionImpl implements CurrentSession {
  CurrentSessionImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> get currentOrgId =>
      _secureStorage.read(key: SecureStorageKeys.currentOrgId);

  @override
  Future<String?> get currentUserId =>
      _secureStorage.read(key: SecureStorageKeys.currentUserId);

  @override
  Future<String?> get currentUserRole =>
      _secureStorage.read(key: SecureStorageKeys.currentUserRole);
}