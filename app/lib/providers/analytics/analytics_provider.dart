import '../../core/result.dart';
import '../../models/credential.dart';
import '../../models/service_ref.dart';
import '../hosting/hosting_provider.dart' show ValidatedAccount;

abstract class AnalyticsProvider {
  AnalyticsProviderId get id;
  String get displayName;

  Future<Result<ValidatedAccount>> validate(Credential credential);
}
