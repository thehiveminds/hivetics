

import '../../core/result.dart';
import '../../models/connection.dart';
import '../../models/project.dart';
import '../../models/deployment.dart';

/// Returned when a credential is successfully validated.
class ValidatedAccount {
  const ValidatedAccount({
    required this.accountId,
    required this.displayName,
    this.teamOptions,
  });

  final String accountId;

  final String displayName;

  final List<AccountOption>? teamOptions;

  bool get requiresTeamPick =>
      teamOptions != null && teamOptions!.length > 1;
}

class AccountOption {
  const AccountOption({required this.id, required this.name});
  final String id;
  final String name;
}

abstract class HostingProvider {
  ProviderId get id;
  String get displayName;

  Future<Result<ValidatedAccount>> validate(
    String token, {
    String? selectedAccountId,
  });

  Future<Result<List<Project>>> listProjects(Connection c, String token);

  Future<Result<List<Deployment>>> listDeployments(
    Connection c,
    String token,
    String projectId, {
    int limit = 20,
    String? cursor,
  });

  Future<Result<List<String>>> listProjectDomains(
    Connection c,
    String token,
    String projectId,
  );
}
