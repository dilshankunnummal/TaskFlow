import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/features/profile/domain/entities/user_profile.dart';
import 'package:taskflow/features/profile/domain/repositories/profile_repository.dart';

@injectable
class GetCurrentUserUseCase {
  final ProfileRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, UserProfile>> call() =>
      _repository.getCurrentUserProfile();
}
