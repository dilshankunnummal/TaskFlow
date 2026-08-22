import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/data/models/session_model.dart';
import 'package:taskflow/features/auth/data/services/token_refresh_service.dart';

final class TokenRefreshServiceImpl implements TokenRefreshService {
  const TokenRefreshServiceImpl();

  @override
  Future<Result<SessionModel>> refresh(String refreshToken) async {
    return const ResultFailure(
      ServerFailure('Refresh token flow is not implemented yet.'),
    );
  }
}
