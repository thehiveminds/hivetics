

/// Canonical deployment / site status shared across all three hosting providers.
enum DeployStatus {
  /// Deploy is live and serving traffic.
  ready,

  /// Build is in progress — initialising, cloning, building, uploading, processing.
  building,

  /// Queued, pending, or needs attention (connection errors, token reconnect).
  queued,

  /// Build FAILED or domain EXPIRED. Do NOT use for unknown states.
  failed,

  /// Cancelled or skipped.
  cancelled,

  /// Unrecognised API value. Renders as grey — "nothing to worry about".
  unknown;

  /// Whether this status represents an actionable alert.
  bool get isAlert => this == failed || this == queued;

  /// Whether this status is terminal (not still running).
  bool get isTerminal =>
      this == ready || this == failed || this == cancelled || this == unknown;
}
