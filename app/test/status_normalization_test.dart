// MIT Licence — TheHiveMinds / Hivetics
// Status normalization unit tests — MANDATORY per ARCHITECTURE §10.
// Test every mapping including the unknown fallback. Getting this wrong
// shows a broken production build as "live" or shows "failed" for an unknown state.

import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/models/deploy_status.dart';
import 'package:hivehub/providers/hosting/status_normalizer.dart';

void main() {
  // ═════════════════════════════════════════════════════════════════════════════
  // VERCEL
  // ═════════════════════════════════════════════════════════════════════════════
  group('Vercel status normalization', () {
    test('READY → ready', () => expect(normalizeVercelStatus('READY'), DeployStatus.ready));
    test('BUILDING → building', () => expect(normalizeVercelStatus('BUILDING'), DeployStatus.building));
    test('QUEUED → queued', () => expect(normalizeVercelStatus('QUEUED'), DeployStatus.queued));
    test('INITIALIZING → queued', () => expect(normalizeVercelStatus('INITIALIZING'), DeployStatus.queued));
    test('ERROR → failed', () => expect(normalizeVercelStatus('ERROR'), DeployStatus.failed));
    test('CANCELED → cancelled', () => expect(normalizeVercelStatus('CANCELED'), DeployStatus.cancelled));
    test('BLOCKED → failed (needs attention: spend cap / deployment protection)', () => expect(normalizeVercelStatus('BLOCKED'), DeployStatus.failed));
    test('DELETED → cancelled', () => expect(normalizeVercelStatus('DELETED'), DeployStatus.cancelled));
    test('lowercase ready → ready (case-insensitive)', () => expect(normalizeVercelStatus('ready'), DeployStatus.ready));
    test('null → unknown', () => expect(normalizeVercelStatus(null), DeployStatus.unknown));
    test('unknown string → unknown (NOT failed)', () => expect(normalizeVercelStatus('SOMETHING_NEW'), DeployStatus.unknown));
    test('empty string → unknown', () => expect(normalizeVercelStatus(''), DeployStatus.unknown));
  });

  // ═════════════════════════════════════════════════════════════════════════════
  // NETLIFY — open enum, anything unmatched must be unknown, NEVER failed
  // ═════════════════════════════════════════════════════════════════════════════
  group('Netlify status normalization', () {
    test('ready → ready', () => expect(normalizeNetlifyStatus('ready'), DeployStatus.ready));
    test('building → building', () => expect(normalizeNetlifyStatus('building'), DeployStatus.building));
    test('uploading → building', () => expect(normalizeNetlifyStatus('uploading'), DeployStatus.building));
    test('uploaded → building', () => expect(normalizeNetlifyStatus('uploaded'), DeployStatus.building));
    test('preparing → building', () => expect(normalizeNetlifyStatus('preparing'), DeployStatus.building));
    test('prepared → building', () => expect(normalizeNetlifyStatus('prepared'), DeployStatus.building));
    test('processing → building', () => expect(normalizeNetlifyStatus('processing'), DeployStatus.building));
    test('retrying → building', () => expect(normalizeNetlifyStatus('retrying'), DeployStatus.building));
    test('new → queued', () => expect(normalizeNetlifyStatus('new'), DeployStatus.queued));
    test('enqueued → queued', () => expect(normalizeNetlifyStatus('enqueued'), DeployStatus.queued));
    test('pending_review → queued', () => expect(normalizeNetlifyStatus('pending_review'), DeployStatus.queued));
    test('accepted → queued', () => expect(normalizeNetlifyStatus('accepted'), DeployStatus.queued));
    test('error → failed', () => expect(normalizeNetlifyStatus('error'), DeployStatus.failed));
    test('canceled → cancelled', () => expect(normalizeNetlifyStatus('canceled'), DeployStatus.cancelled));
    test('skipped → cancelled', () => expect(normalizeNetlifyStatus('skipped'), DeployStatus.cancelled));
    test('deleted → cancelled', () => expect(normalizeNetlifyStatus('deleted'), DeployStatus.cancelled));
    test('null → unknown', () => expect(normalizeNetlifyStatus(null), DeployStatus.unknown));
    // The most important case: unrecognised value must NEVER be failed.
    test('future_unknown_value → unknown (NOT failed)', () =>
        expect(normalizeNetlifyStatus('some_future_state'), DeployStatus.unknown));
  });

  // ═════════════════════════════════════════════════════════════════════════════
  // CLOUDFLARE PAGES — derived from latest_stage; the pipeline trap
  // ═════════════════════════════════════════════════════════════════════════════
  group('Cloudflare Pages status normalization', () {
    // Failure
    test('any stage + failure → failed',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'build', stageStatus: 'failure'), DeployStatus.failed));
    test('deploy + failure → failed',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'deploy', stageStatus: 'failure'), DeployStatus.failed));

    // Cancelled
    test('any stage + canceled → cancelled',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'build', stageStatus: 'canceled'), DeployStatus.cancelled));

    // The key trap: success on non-deploy stage = STILL BUILDING
    test('build + success → building (NOT ready) ⚠️ trap',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'build', stageStatus: 'success'), DeployStatus.building));
    test('initialize + success → building',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'initialize', stageStatus: 'success'), DeployStatus.building));
    test('clone_repo + success → building',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'clone_repo', stageStatus: 'success'), DeployStatus.building));

    // Only deploy + success = ready
    test('deploy + success → ready ✓',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'deploy', stageStatus: 'success'), DeployStatus.ready));

    // Active
    test('queued + active → queued',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'queued', stageStatus: 'active'), DeployStatus.queued));
    test('build + active → building',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'build', stageStatus: 'active'), DeployStatus.building));
    test('deploy + active → building',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'deploy', stageStatus: 'active'), DeployStatus.building));

    // Idle
    test('any stage + idle → queued',
        () => expect(normalizeCloudflarePagesStatus(stageName: 'build', stageStatus: 'idle'), DeployStatus.queued));

    // Nulls
    test('null stage → unknown', () =>
        expect(normalizeCloudflarePagesStatus(stageName: null, stageStatus: 'success'), DeployStatus.unknown));
    test('null status → unknown', () =>
        expect(normalizeCloudflarePagesStatus(stageName: 'deploy', stageStatus: null), DeployStatus.unknown));
    test('unknown status → unknown (NOT failed)', () =>
        expect(normalizeCloudflarePagesStatus(stageName: 'deploy', stageStatus: 'new_value'), DeployStatus.unknown));
  });
}
