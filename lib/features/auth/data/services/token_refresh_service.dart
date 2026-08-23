import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/data/models/refreshed_tokens.dart';

abstract interface class TokenRefreshService {
  Future<Result<RefreshedTokens>> refresh(String refreshToken);
}