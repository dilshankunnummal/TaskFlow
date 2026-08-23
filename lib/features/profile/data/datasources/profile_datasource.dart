import 'package:injectable/injectable.dart';
import 'package:taskflow/core/auth/current_session.dart';
import 'package:taskflow/core/data/mock_json_data_source.dart';
import 'package:taskflow/core/error/failures.dart';
import 'package:taskflow/core/network/mock_network.dart';
import 'package:taskflow/features/profile/data/models/user_profile_model.dart';

abstract class ProfileDataSource {
  Future<UserProfileModel> getCurrentUserProfile();
}

@LazySingleton(as: ProfileDataSource)
class MockProfileDataSource implements ProfileDataSource {
  final MockJsonDataSource _jsonDataSource;
  final CurrentSession _session;
  final MockNetwork _network;

  MockProfileDataSource(
    this._jsonDataSource,
    this._session,
    this._network,
  );

  @override
  Future<UserProfileModel> getCurrentUserProfile() async {
    await _network.simulateDelay();

    if (!_network.isOnline) {
      throw const OfflineFailure(null);
    }

    final userId = await _session.currentUserId ?? 'user_001';
    final orgId = await _session.currentOrgId ?? 'org_a1b2c3';
    final role = await _session.currentUserRole ?? 'org_admin';

    final userRows = await _jsonDataSource.section('users');
    final userRow = userRows.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => userRows.isNotEmpty ? userRows.first : const <String, dynamic>{},
    );

    if (userRow.isEmpty) {
      throw const NotFoundFailure('User profile not found.');
    }

    final orgRows = await _jsonDataSource.section('organizations');
    final orgRow = orgRows.firstWhere(
      (o) => o['id'] == orgId,
      orElse: () => orgRows.isNotEmpty ? orgRows.first : const <String, dynamic>{},
    );

    final orgName = orgRow['name'] as String? ?? 'Nimbus Digital';

    return UserProfileModel.fromJson(
      userRow,
      organizationName: orgName,
      role: role,
    );
  }
}
