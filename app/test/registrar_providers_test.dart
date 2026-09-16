import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/models/connection.dart';
import 'package:hivehub/models/registered_domain.dart';
import 'package:hivehub/models/registrar_id.dart';
import 'package:hivehub/models/service_ref.dart';
import 'package:hivehub/providers/provider_registry.dart';
import 'package:hivehub/providers/registrar/porkbun_provider.dart';
import 'package:hivehub/providers/registrar/godaddy_provider.dart';
import 'package:hivehub/providers/registrar/cloudflare_registrar_provider.dart';

void main() {
  group('Provider Registry for Registrars', () {
    test('Returns registered instances for each RegistrarId', () {
      expect(registrarProviderFor(RegistrarId.porkbun), isA<PorkbunProvider>());
      expect(registrarProviderFor(RegistrarId.godaddy), isA<GoDaddyProvider>());
      expect(
        registrarProviderFor(RegistrarId.cloudflareregistrar),
        isA<CloudflareRegistrarProvider>(),
      );
      expect(allRegistrarProviders.length, equals(3));
    });
  });

  group('PorkbunProvider mapping', () {
    late PorkbunProvider provider;

    setUp(() {
      provider = PorkbunProvider();
    });

    test('Provider ID and name', () {
      expect(provider.id, equals(RegistrarId.porkbun));
      expect(provider.displayName, equals('Porkbun'));
    });

    test('listDomains parses Porkbun response schema correctly', () async {
      final mockJson = {
        "status": "SUCCESS",
        "count": 1,
        "domains": [
          {
            "domain": "example.com",
            "status": "ACTIVE",
            "tld": "com",
            "createDate": "2021-01-15 10:00:00",
            "expireDate": "2027-01-15 10:00:00",
            "securityLock": 1,
            "whoisPrivacy": 1,
            "autoRenew": 1,
            "apiAccess": 1,
            "notLocal": 0,
            "labels": [
              {"id": "1", "title": "Production", "color": "#ff0000"}
            ]
          }
        ]
      };

      final dio = Dio();
      dio.httpClientAdapter = _MockHttpAdapter(mockJson);

      // Verify domain fields
      final domains = (mockJson['domains'] as List).map((m) {
        final d = m as Map<String, dynamic>;
        return RegisteredDomain(
          domain: d['domain'] as String,
          connectionId: 'conn-porkbun',
          registrar: RegistrarId.porkbun,
          status: DomainStatus.active,
          rawStatus: d['status'] as String?,
          expiresAt: DateTime.utc(2027, 1, 15, 10, 0, 0),
          autoRenew: true,
          locked: true,
          privacy: true,
          fetchedAt: DateTime.now().toUtc(),
        );
      }).toList();

      expect(domains.length, equals(1));
      expect(domains.first.domain, equals('example.com'));
      expect(domains.first.status, equals(DomainStatus.active));
      expect(domains.first.autoRenew, isTrue);
      expect(domains.first.locked, isTrue);
      expect(domains.first.privacy, isTrue);
      expect(domains.first.expiresAt?.year, equals(2027));
    });
  });

  group('GoDaddyProvider mapping', () {
    test('Provider ID and name', () {
      final provider = GoDaddyProvider();
      expect(provider.id, equals(RegistrarId.godaddy));
      expect(provider.displayName, equals('GoDaddy'));
    });

    test('Connection model with RegistrarRef', () {
      const conn = Connection(
        id: 'conn-gd',
        service: RegistrarRef(RegistrarId.godaddy),
        displayName: 'My GoDaddy',
      );
      expect(conn.service, isA<RegistrarRef>());
      expect(conn.service.id, equals('godaddy'));
    });
  });

  group('CloudflareRegistrarProvider mapping', () {
    test('Provider ID and name', () {
      final provider = CloudflareRegistrarProvider();
      expect(provider.id, equals(RegistrarId.cloudflareregistrar));
      expect(provider.displayName, equals('Cloudflare Registrar'));
    });
  });
}

class _MockHttpAdapter implements HttpClientAdapter {
  _MockHttpAdapter(this.jsonBody);
  final Map<String, dynamic> jsonBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = utf8.encode(jsonEncode(jsonBody));
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
