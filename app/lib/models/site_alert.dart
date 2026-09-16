

/// Alert severity — maps to statusQueued (warning) or statusFailed (error).
enum AlertSeverity { warning, error }

class SiteAlert {
  const SiteAlert({
    required this.severity,
    required this.message,
  });

  final AlertSeverity severity;

  final String message;

  bool get isError   => severity == AlertSeverity.error;
  bool get isWarning => severity == AlertSeverity.warning;

  // Phase 1 factory constructors

  /// Last build failed.
  static const buildFailed = SiteAlert(
    severity: AlertSeverity.error,
    message: 'Last build failed',
  );

  /// Token needs reconnecting.
  static SiteAlert tokenExpired(String providerName) => SiteAlert(
        severity: AlertSeverity.warning,
        message: 'Reconnect $providerName',
      );


}
