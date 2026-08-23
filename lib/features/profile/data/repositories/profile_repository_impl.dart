import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/connectivity_manager.dart';
import 'package:taskflow/core/utils/logger.dart';
import 'package:taskflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:taskflow/features/profile/data/datasources/profile_datasource.dart';
import 'package:taskflow/features/profile/domain/entities/user_profile.dart';
import 'package:taskflow/features/profile/domain/repositories/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;
  final AuthRepository _authRepository;
  final ConnectivityManager _connectivityManager;

  UserProfile? _cachedProfile;

  ProfileRepositoryImpl(
    this._dataSource,
    this._authRepository,
    this._connectivityManager,
  );

  @override
  Future<Either<Failure, UserProfile>> getCurrentUserProfile() async {
    if (!_connectivityManager.isOnline) {
      if (_cachedProfile != null) {
        return Right(_cachedProfile!);
      }
      return const Left(OfflineFailure(null));
    }

    try {
      final profile = await _dataSource.getCurrentUserProfile();
      _cachedProfile = profile;
      return Right(profile);
    } on OfflineFailure {
      if (_cachedProfile != null) {
        return Right(_cachedProfile!);
      }
      return const Left(OfflineFailure(null));
    } catch (error, stackTrace) {
      AppLogger.error(
        'ProfileRepositoryImpl.getCurrentUserProfile failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (_cachedProfile != null) {
        return Right(_cachedProfile!);
      }
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final result = await _authRepository.logout();
      if (result.isSuccess) {
        _cachedProfile = null;
        return const Right(null);
      }
      return Left(UnknownFailure(result.failureOrNull?.message ?? 'Logout failed'));
    } catch (error, stackTrace) {
      AppLogger.error(
        'ProfileRepositoryImpl.logout failed',
        error: error,
        stackTrace: stackTrace,
      );
      return const Left(UnknownFailure());
    }
  }
}
