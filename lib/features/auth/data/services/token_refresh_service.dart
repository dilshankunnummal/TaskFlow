import 'package:taskflow/core/error/result.dart';
import 'package:taskflow/features/auth/data/models/session_model.dart';

abstract interface class TokenRefreshService {
  Future<Result<SessionModel>> refresh(String refreshToken);
}
