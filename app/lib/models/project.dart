

import 'connection.dart';
import 'deployment.dart';

class Project {
  const Project({
    required this.id,
    required this.connectionId,
    required this.providerId,
    required this.name,
    this.framework,
    this.productionBranch,
    this.domains = const [],
    this.latestDeployment,
    this.updatedAt,
    this.fetchedAt,
  });

  final String id;
  final String connectionId;
  final ProviderId providerId;

  final String name;

  final String? framework;

  final String? productionBranch;

  final List<String> domains;
  final Deployment? latestDeployment;

  final DateTime? updatedAt;
  final DateTime? fetchedAt;

  String? get primaryDomain => domains.isNotEmpty ? domains.first : null;

  String dashboardUrl([String? accountId]) {
    switch (providerId) {
      case ProviderId.vercel:
        return 'https://vercel.com/~/projects/$name';
      case ProviderId.netlify:
        return 'https://app.netlify.com/sites/$name/overview';
      case ProviderId.cloudflarepages:
        if (accountId != null && accountId.isNotEmpty) {
          return 'https://dash.cloudflare.com/$accountId/pages/view/$name';
        }
        return 'https://dash.cloudflare.com/?to=/:account/pages/view/$name';
    }
  }

  Project copyWith({
    List<String>? domains,
    DateTime? fetchedAt,
    Deployment? latestDeployment,
  }) =>
      Project(
        id: id,
        connectionId: connectionId,
        providerId: providerId,
        name: name,
        framework: framework,
        productionBranch: productionBranch,
        domains: domains ?? this.domains,
        latestDeployment: latestDeployment ?? this.latestDeployment,
        updatedAt: updatedAt,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
}
