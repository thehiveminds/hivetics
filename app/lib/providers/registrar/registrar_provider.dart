import '../../core/result.dart';
import '../../models/connection.dart';
import '../../models/credential.dart';
import '../../models/dns_record.dart';
import '../../models/registered_domain.dart';
import '../../models/registrar_id.dart';
import '../hosting/hosting_provider.dart' show ValidatedAccount;

abstract class RegistrarProvider {
  RegistrarId get id;
  String get displayName;

  /// Validate credential against provider API.
  Future<Result<ValidatedAccount>> validate(Credential credential);

  /// List registered domains under this connection.
  Future<Result<List<RegisteredDomain>>> listDomains(
    Connection c,
    Credential credential,
  );

  /// Fetch DNS records for a given domain managed by this registrar.
  Future<Result<List<DnsRecord>>> listDnsRecords(
    Connection c,
    Credential credential,
    String domain,
  );
}
