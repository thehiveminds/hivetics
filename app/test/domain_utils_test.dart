// MIT Licence — TheHiveMinds / Hivetics
// domain_utils unit tests. BUILD-PLAN §Phase 1 — build + test now.

import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/shared/domain_utils.dart';

void main() {
  group('normalizeDomain', () {
    test('bare domain passes through', () => expect(normalizeDomain('thehiveminds.in'), 'thehiveminds.in'));
    test('strips https://', () => expect(normalizeDomain('https://thehiveminds.in'), 'thehiveminds.in'));
    test('strips http://', () => expect(normalizeDomain('http://thehiveminds.in'), 'thehiveminds.in'));
    test('strips www.', () => expect(normalizeDomain('www.thehiveminds.in'), 'thehiveminds.in'));
    test('strips https://www.', () => expect(normalizeDomain('https://www.thehiveminds.in'), 'thehiveminds.in'));
    test('strips path', () => expect(normalizeDomain('https://thehiveminds.in/blog/post'), 'thehiveminds.in'));
    test('strips query', () => expect(normalizeDomain('thehiveminds.in?ref=test'), 'thehiveminds.in'));
    test('strips sc-domain: prefix', () => expect(normalizeDomain('sc-domain:thehiveminds.in'), 'thehiveminds.in'));
    test('lowercases', () => expect(normalizeDomain('THEHIVEMINDS.IN'), 'thehiveminds.in'));
    test('trims whitespace', () => expect(normalizeDomain('  thehiveminds.in  '), 'thehiveminds.in'));
    test('pages.dev subdomain', () => expect(normalizeDomain('mysite.pages.dev'), 'mysite.pages.dev'));
  });

  group('sameDomain', () {
    test('same bare domains', () => expect(sameDomain('example.com', 'example.com'), true));
    test('https vs bare', () => expect(sameDomain('https://example.com', 'example.com'), true));
    test('www vs bare', () => expect(sameDomain('www.example.com', 'example.com'), true));
    test('different domains', () => expect(sameDomain('example.com', 'other.com'), false));
    test('sc-domain vs bare', () => expect(sameDomain('sc-domain:example.com', 'example.com'), true));
  });
}
