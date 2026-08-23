import 'package:taskflow/core/data/mock_json_loader.dart';
import 'package:taskflow/core/error/exceptions.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/core/network/simulated_network.dart';
import 'package:taskflow/core/utils/id_generator.dart';
import 'package:taskflow/features/auth/data/models/refreshed_tokens.dart';
import 'package:taskflow/features/auth/data/services/token_refresh_service.dart';

final class TokenRefreshServiceImpl implements TokenRefreshService {
  TokenRefreshServiceImpl(this._simulatedNetwork, this._mockJsonLoader, this._idGenerator);

  final SimulatedNetwork _simulatedNetwork;
  final MockJsonLoader _mockJsonLoader;
  final IdGenerator _idGenerator;

  static const String _validRefreshTokenPrefix = 'refresh-';

  @override
  Future<Result<RefreshedTokens>> refresh(String refreshToken) {
    return Result.guard(() async {
      await _simulatedNetwork.delay();
      _simulatedNetwork.throwIfForced(refreshToken);

      if (!refreshToken.startsWith(_validRefreshTokenPrefix)) {
        throw const AuthException('The refresh token is invalid or has expired.');
      }

      final authMock = await _mockJsonLoader.object('auth_mock');
      final mockLoginResponse = authMock['mock_login_response'] as Map<String, dynamic>;
      final expiresInSeconds = mockLoginResponse['access_token_expires_in_seconds'] as int;

      return RefreshedTokens(
        accessToken: 'access-${_idGenerator.generate()}',
        refreshToken: 'refresh-${_idGenerator.generate()}',
        expiresInSeconds: expiresInSeconds,
      );
    });
  }
}