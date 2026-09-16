

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

  // Phase 2 domain alerts (§6.2)

  /// Domain expired (daysUntilExpiry <= 0).
  static const domainExpired = SiteAlert(
    severity: AlertSeverity.error,
    message: 'Domain expired',
  );

  /// Domain expiring within 30 days.
  static SiteAlert domainExpiring(int days) => SiteAlert(
        severity: AlertSeverity.warning,
        message: days == 1 ? 'Expires in 1 day' : 'Expires in $days days',
      );

  /// Auto-renew is turned off when domain expires within 60 days.
  static const autoRenewOff = SiteAlert(
    severity: AlertSeverity.warning,
    message: 'Auto-renew is off',
  );
}
