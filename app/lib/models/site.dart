

import 'project.dart';
import 'deployment.dart';
import 'registered_domain.dart';
import 'site_alert.dart';

class Site {
  const Site({
    required this.id,
    required this.displayName,
    this.domain,
    this.hostProject,
    this.latestDeployment,
    this.alerts = const [],
    this.registration,
    this.gscSiteUrl,
    this.ga4PropertyId,
    this.clarityProjectId,
  });

  final String id;

  final String displayName;

  final String? domain;

  final Project? hostProject;

  final Deployment? latestDeployment;

  final List<SiteAlert> alerts;

  final RegisteredDomain? registration;

  final String? gscSiteUrl;
  final String? ga4PropertyId;
  final String? clarityProjectId;

  bool get hasAlerts => alerts.isNotEmpty;

  bool get hasError => alerts.any((a) => a.isError);

  DateTime get sortKey =>
      latestDeployment?.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  Site copyWith({
    List<SiteAlert>? alerts,
    Deployment? latestDeployment,
    Project? hostProject,
    RegisteredDomain? registration,
    bool clearRegistration = false,
  }) =>
      Site(
        id: id,
        displayName: displayName,
        domain: domain,
        hostProject: hostProject ?? this.hostProject,
        latestDeployment: latestDeployment ?? this.latestDeployment,
        alerts: alerts ?? this.alerts,
        registration: clearRegistration
            ? null
            : (registration ?? this.registration),
        gscSiteUrl: gscSiteUrl,
        ga4PropertyId: ga4PropertyId,
        clarityProjectId: clarityProjectId,
      );
}
