import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskflow/core/constants/storage_keys.dart';
import 'package:taskflow/core/data/mock_json_loader.dart';
import 'package:taskflow/core/error/exceptions.dart';
import 'package:taskflow/core/network/simulated_network.dart';
import 'package:taskflow/core/utils/id_generator.dart';
import 'package:taskflow/features/auth/data/models/login_request.dart';
import 'package:taskflow/features/auth/data/models/login_response.dart';
import 'package:taskflow/features/auth/data/models/session_model.dart';
import 'package:taskflow/features/auth/data/models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<bool> hasValidSession();

  Future<LoginResponse> login(LoginRequest request);

  Future<void> persistSession(SessionModel session);

  Future<void> clearSession();

  Future<UserModel?> getCurrentUser();
}

final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(
    this._secureStorage,
    this._mockJsonLoader,
    this._simulatedNetwork,
    this._idGenerator,
  );

  final FlutterSecureStorage _secureStorage;
  final MockJsonLoader _mockJsonLoader;
  final SimulatedNetwork _simulatedNetwork;
  final IdGenerator _idGenerator;

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

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    await _simulatedNetwork.delay();
    _simulatedNetwork.throwIfForced(request.email.trim().toLowerCase());

    final authMock = await _mockJsonLoader.object('auth_mock');
    final credentials = (authMock['test_credentials'] as List).cast<Map<String, dynamic>>();
    final expiresInSeconds = authMock['access_token_expires_in_seconds'] as int;

    final normalizedEmail = request.email.trim().toLowerCase();
    Map<String, dynamic>? matchedCredential;
    for (final credential in credentials) {
      final credentialEmail = (credential['email'] as String).trim().toLowerCase();
      if (credentialEmail == normalizedEmail && credential['password'] == request.password) {
        matchedCredential = credential;
        break;
      }
    }

    if (matchedCredential == null) {
      throw const AuthException('Invalid email or password.');
    }

    final users = await _mockJsonLoader.section('users');
    Map<String, dynamic>? matchedUser;
    for (final user in users) {
      if (user['id'] == matchedCredential['user_id']) {
        matchedUser = user;
        break;
      }
    }

    if (matchedUser == null) {
      throw const NotFoundException('No account found for these credentials.');
    }

    final userModel = UserModel.fromJson(matchedUser, orgId: matchedCredential['org_id'] as String);

    return LoginResponse(
      accessToken: 'access-${_idGenerator.generate()}',
      refreshToken: 'refresh-${_idGenerator.generate()}',
      expiresInSeconds: expiresInSeconds,
      user: userModel,
    );
  }

  @override
  Future<void> persistSession(SessionModel session) async {
    try {
      await Future.wait([
        _secureStorage.write(key: SecureStorageKeys.accessToken, value: session.accessToken),
        _secureStorage.write(key: SecureStorageKeys.refreshToken, value: session.refreshToken),
        _secureStorage.write(
          key: SecureStorageKeys.accessTokenExpiresAt,
          value: session.accessTokenExpiresAt.toIso8601String(),
        ),
        _secureStorage.write(key: SecureStorageKeys.currentUserId, value: session.userId),
        _secureStorage.write(key: SecureStorageKeys.currentOrgId, value: session.orgId),
        _secureStorage.write(key: SecureStorageKeys.currentUserRole, value: session.role),
        _secureStorage.write(
          key: SecureStorageKeys.loginTimestamp,
          value: session.loginTimestamp.toIso8601String(),
        ),
      ]);
    } catch (_) {
      throw const CacheException('Unable to persist the authentication session.');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: SecureStorageKeys.accessToken),
        _secureStorage.delete(key: SecureStorageKeys.refreshToken),
        _secureStorage.delete(key: SecureStorageKeys.accessTokenExpiresAt),
        _secureStorage.delete(key: SecureStorageKeys.currentUserId),
        _secureStorage.delete(key: SecureStorageKeys.currentOrgId),
        _secureStorage.delete(key: SecureStorageKeys.currentUserRole),
        _secureStorage.delete(key: SecureStorageKeys.loginTimestamp),
      ]);
    } catch (_) {
      throw const CacheException('Unable to clear the authentication session.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await _secureStorage.read(key: SecureStorageKeys.currentUserId);
      if (userId == null) {
        return null;
      }

      final orgId = await _secureStorage.read(key: SecureStorageKeys.currentOrgId) ?? '';
      final users = await _mockJsonLoader.section('users');
      Map<String, dynamic>? matchedUser;
      for (final user in users) {
        if (user['id'] == userId) {
          matchedUser = user;
          break;
        }
      }

      if (matchedUser == null) {
        return null;
      }

      return UserModel.fromJson(matchedUser, orgId: orgId);
    } catch (_) {
      throw const CacheException('Unable to read the current user.');
    }
  }
}
