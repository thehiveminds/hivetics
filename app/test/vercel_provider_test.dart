import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/models/connection.dart';
import 'package:hivehub/models/service_ref.dart';
import 'package:hivehub/providers/hosting/status_normalizer.dart';
import 'package:hivehub/providers/hosting/vercel_provider.dart';

void main() {
  group('VercelProvider Domain Extraction & Mapping', () {
    test('Timestamp parser handles ms epoch and null', () {
      final dt = parseVercelTimestamp(1771863211279);
      expect(dt, isNotNull);
      expect(dt!.millisecondsSinceEpoch, equals(1771863211279));

      expect(parseVercelTimestamp(null), isNull);
      expect(parseVercelTimestamp('invalid'), isNull);
    });

    test('normalizeUrl prepends https:// if scheme is missing', () {
      expect(normalizeUrl('app.vercel.app'), equals('https://app.vercel.app'));
      expect(
        normalizeUrl('https://app.vercel.app'),
        equals('https://app.vercel.app'),
      );
      expect(
        normalizeUrl('http://app.vercel.app'),
        equals('http://app.vercel.app'),
      );
      expect(normalizeUrl(null), isNull);
      expect(normalizeUrl(''), isNull);
    });

    test('Provider ID and name', () {
      final provider = VercelProvider();
      expect(provider.id, equals(ProviderId.vercel));
      expect(provider.displayName, equals('Vercel'));
    });

    test('Connection model with teamId vs personal account', () {
      const teamConn = Connection(
        id: 'conn-1',
        service: HostRef(ProviderId.vercel),
        displayName: 'My Team',
        accountId: 'team_12345',
      );
      expect(teamConn.accountId?.startsWith('team_'), isTrue);

      const personalConn = Connection(
        id: 'conn-2',
        service: HostRef(ProviderId.vercel),
        displayName: 'Personal',
        accountId: 'personal',
      );
      expect(personalConn.accountId?.startsWith('team_'), isFalse);
    });
  });
}
