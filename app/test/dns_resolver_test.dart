import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/core/network/dns_resolver.dart';

void main() {
  group('DnsResolver', () {
    test('parses and cleans DNS response answers correctly', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final type = options.queryParameters['type'];

            if (type == 'A') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'Status': 0,
                    'Answer': [
                      {
                        'name': 'example.com.',
                        'type': 1,
                        'TTL': 300,
                        'data': '93.184.216.34',
                      },
                    ],
                  },
                ),
              );
            }

            if (type == 'MX') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'Status': 0,
                    'Answer': [
                      {
                        'name': 'example.com.',
                        'type': 15,
                        'TTL': 3600,
                        'data': '10 mail.example.com.',
                      },
                    ],
                  },
                ),
              );
            }

            if (type == 'TXT') {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'Status': 0,
                    'Answer': [
                      {
                        'name': 'example.com.',
                        'type': 16,
                        'TTL': 300,
                        'data': '"v=spf1 include:_spf.google.com ~all"',
                      },
 ],
 },
 ),
 );
 }

 return handler.resolve(
 Response(
 requestOptions: options,
 statusCode: 200,
 data: {'Status': 0, 'Answer': []},
 ),
 );
 },
 ),
 );

 final resolver = DnsResolver(dio: dio);
 final records = await resolver.resolveLiveRecords('example.com');

 expect(records.length, 3);

 final aRecord = records.firstWhere((r) => r.type == 'A');
 expect(aRecord.name, '@');
 expect(aRecord.content, '93.184.216.34');
 expect(aRecord.ttl, 300);

 final mxRecord = records.firstWhere((r) => r.type == 'MX');
 expect(mxRecord.priority, 10);
 expect(mxRecord.content, 'mail.example.com');

 final txtRecord = records.firstWhere((r) => r.type == 'TXT');
 expect(txtRecord.content, 'v=spf1 include:_spf.google.com ~all');
 });

 test('returns empty list for blank or invalid domain', () async {
 final resolver = DnsResolver();
 final records = await resolver.resolveLiveRecords(' ');
 expect(records, isEmpty);
 });
 });
}
