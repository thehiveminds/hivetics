import '../../core/network/api_exception.dart';
import '../../core/result.dart';
import '../../models/credential.dart';
import '../../models/service_ref.dart';
import '../hosting/hosting_provider.dart' show ValidatedAccount;
import 'analytics_provider.dart';

class GenericAnalyticsProvider implements AnalyticsProvider {
  const GenericAnalyticsProvider(this.id);

  @override
  final AnalyticsProviderId id;

  @override
  String get displayName => id.displayName;

  @override
  Future<Result<ValidatedAccount>> validate(Credential credential) async {
    final token = switch (credential) {
      BearerCredential(:final token) => token.trim(),
      OAuthCredential(:final accessToken) => accessToken.trim(),
      KeyPairCredential(:final apiKey) => apiKey.trim(),
    };
    if (token.isEmpty) {
      return const Err(UnauthorizedException('API token or key cannot be empty'));
    }
    return Ok(ValidatedAccount(
      accountId: '${id.name}_account',
      displayName: displayName,
    ));
  }
}
