

import 'deploy_status.dart';

class Deployment {
  const Deployment({
    required this.id,
    required this.projectId,
    required this.connectionId,
    required this.status,
    required this.createdAt,
    this.url,
    this.branch,
    this.environment,
    this.duration,
    this.errorMessage,
    this.commitMessage,
    this.commitSha,
    this.commitAuthor,
  });

  final String id;
  final String projectId;
  final String connectionId;

  final DeployStatus status;

  final String? url;

  final String? branch;

  final String? environment;

  final Duration? duration;

  final String? errorMessage;

  final String? commitMessage;
  final String? commitSha;
  final String? commitAuthor;

  final DateTime createdAt;

  bool get isProduction => environment == 'production';

  Deployment copyWith({DeployStatus? status}) => Deployment(
        id: id,
        projectId: projectId,
        connectionId: connectionId,
        status: status ?? this.status,
        createdAt: createdAt,
        url: url,
        branch: branch,
        environment: environment,
        duration: duration,
        errorMessage: errorMessage,
        commitMessage: commitMessage,
        commitSha: commitSha,
        commitAuthor: commitAuthor,
      );
}
