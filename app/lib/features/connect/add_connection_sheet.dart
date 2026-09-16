import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/network/api_exception.dart';
import '../../models/connection.dart';
import '../../providers/hosting/hosting_provider.dart';
import '../../providers/provider_registry.dart';
import '../../shared/haptics.dart';
import '../../shared/theme.dart';
import '../../state/connections_notifier.dart';
import '../../state/sites_notifier.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/provider_badge.dart';

class AddConnectionSheet extends ConsumerStatefulWidget {
  const AddConnectionSheet({super.key});

  @override
  ConsumerState<AddConnectionSheet> createState() => _AddConnectionSheetState();
}

enum _Step { pickProvider, enterToken, validating, pickAccount, nameIt }

class _AddConnectionSheetState extends ConsumerState<AddConnectionSheet> {
  _Step _step = _Step.pickProvider;
  ProviderId? _provider;
  String _token = '';
  bool _tokenObscured = true;
  List<AccountOption>? _accountOptions;
  String? _selectedAccountId;
  String? _errorMessage;
  String? _createdConnectionId;

  final _tokenController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = context.hh;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        expand: false,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: hh.bgElevated,
            borderRadius: HHRadius.sheetBr(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: HHSpacing.sm),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: hh.fill,
                    borderRadius: HHRadius.pillBr(),
                  ),
                ),
              ),
              const SizedBox(height: HHSpacing.md),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: HHSpacing.lg),
                child: Row(
                  children: [
                    if (_step != _Step.pickProvider && _step != _Step.nameIt)
                      Padding(
                        padding: const EdgeInsets.only(right: HHSpacing.sm),
                        child: AppPressable(
                          onTap: () {
                            setState(() {
                              if (_step == _Step.pickAccount) {
                                _step = _Step.enterToken;
                              } else {
                                _step = _Step.pickProvider;
                              }
                              _errorMessage = null;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: hh.bgElevated2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              LucideIcons.arrowLeft,
                              color: hh.textPrimary,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        _titleForStep(),
                        style: hh.title2().copyWith(fontSize: 20),
                      ),
                    ),
                    AppPressable(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hh.bgElevated2,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.x,
                          color: hh.textTertiary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: HHSpacing.md),
              Divider(height: 0.5, thickness: 0.5, color: hh.separator),
              const SizedBox(height: HHSpacing.md),

              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(
                    horizontal: HHSpacing.screenPadding,
                  ),
                  child: _buildStep(hh),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _titleForStep() => switch (_step) {
        _Step.pickProvider => 'Add Connection',
        _Step.enterToken => 'Enter API Token',
        _Step.validating => 'Verifying…',
        _Step.pickAccount => 'Choose Account',
        _Step.nameIt => 'Connection Details',
      };

  Widget _buildStep(HHTokens hh) {
    return switch (_step) {
      _Step.pickProvider => _ProviderPicker(
          onPick: _onProviderPicked,
          hh: hh,
        ),
      _Step.enterToken => _TokenEntry(
          provider: _provider!,
          controller: _tokenController,
          obscured: _tokenObscured,
          errorMessage: _errorMessage,
          onToggleObscure: () =>
              setState(() => _tokenObscured = !_tokenObscured),
          onPaste: _paste,
          onSubmit: _validate,
          hh: hh,
        ),
      _Step.validating => _ValidatingState(hh: hh),
      _Step.pickAccount => _AccountPicker(
          options: _accountOptions!,
          onPick: _onAccountPicked,
          hh: hh,
        ),
      _Step.nameIt => _NameStep(
          controller: _nameController,
          onDone: _save,
          hh: hh,
        ),
    };
  }

  void _onProviderPicked(ProviderId p) {
    setState(() {
      _provider = p;
      _step = _Step.enterToken;
      _errorMessage = null;
    });
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _tokenController.text = data!.text!.trim();
      _token = _tokenController.text;
    }
  }

  Future<void> _validate() async {
    _token = _tokenController.text.trim();
    if (_token.isEmpty) {
      setState(() => _errorMessage = 'Please paste your API token above');
      return;
    }
    setState(() {
      _step = _Step.validating;
      _errorMessage = null;
    });

    final provider = providerFor(_provider!);
    final valResult = await provider.validate(
      _token,
      selectedAccountId: _selectedAccountId,
    );

    valResult.when(
      ok: (account) async {
        if (account.requiresTeamPick && _selectedAccountId == null) {
          setState(() {
            _accountOptions = account.teamOptions;
            _step = _Step.pickAccount;
          });
          return;
        }

        // Account is chosen or single — save connection
        await _createAndFinalizeConnection(
          selectedAccountId: _selectedAccountId ?? account.accountId,
        );
      },
      err: (e) {
        setState(() {
          _step = _Step.enterToken;
          _errorMessage = _friendlyError(e);
        });
      },
    );
  }

  Future<void> _createAndFinalizeConnection({String? selectedAccountId}) async {
    final result = await ref.read(connectionsProvider.notifier).addConnection(
          providerId: _provider!,
          token: _token,
          selectedAccountId: selectedAccountId,
        );

    result.when(
      ok: (connection) {
        _createdConnectionId = connection.id;
        _nameController.text = connection.displayName;
        setState(() => _step = _Step.nameIt);
      },
      err: (e) {
        setState(() {
          _step = _Step.enterToken;
          _errorMessage = _friendlyError(e);
        });
      },
    );
  }

  void _onAccountPicked(String accountId, String name) {
    setState(() {
      _selectedAccountId = accountId;
      _step = _Step.validating;
    });
    _createAndFinalizeConnection(selectedAccountId: accountId);
  }

  Future<void> _save() async {
    HHHaptics.lightImpact();
    final customName = _nameController.text.trim();
    if (customName.isNotEmpty && _createdConnectionId != null) {
      await ref
          .read(connectionsProvider.notifier)
          .updateDisplayName(_createdConnectionId!, customName);
    }
    // Refresh sites feed immediately
    ref.invalidate(sitesProvider);
    if (mounted) Navigator.of(context).pop();
  }

  String _friendlyError(ApiException e) => switch (e) {
        UnauthorizedException() =>
          'Invalid token — check that you copied the complete token.',
        ForbiddenException() =>
          'Token lacks required permissions. Check instructions below.',
        NotFoundException() => 'Account not found — verify your token scope.',
        RateLimitedException() => 'Rate limited — wait a moment and try again.',
        NetworkException() => 'Network connection error — check internet.',
        UnknownException() => e.message,
      };
}

class _ProviderPicker extends StatelessWidget {
  const _ProviderPicker({required this.onPick, required this.hh});
  final ValueChanged<ProviderId> onPick;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select a hosting platform to link with HiveHub.',
          style: hh.body().copyWith(color: hh.textSecondary),
        ),
        const SizedBox(height: HHSpacing.lg),
        ...ProviderId.values.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: HHSpacing.md),
              child: _ProviderCard(
                provider: p,
                onPick: onPick,
                hh: hh,
              ),
            )),
        const SizedBox(height: HHSpacing.xl),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.onPick,
    required this.hh,
  });

  final ProviderId provider;
  final ValueChanged<ProviderId> onPick;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (provider) {
      ProviderId.vercel => 'Next.js, frontend & serverless deployments',
      ProviderId.netlify => 'Web apps, edge functions & custom domains',
      ProviderId.cloudflarepages => 'Edge hosting & unlimited preview branches',
    };

    return AppPressable(
      onTap: () {
        HHHaptics.selectionClick();
        onPick(provider);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(HHSpacing.lg),
        decoration: BoxDecoration(
          color: hh.bgElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: hh.cardBorder.withValues(alpha: 0.8)),
          boxShadow: hh.cardShadow,
        ),
        child: Row(
          children: [
            ProviderBadge(providerId: provider, showLabel: false, size: 36),
            const SizedBox(width: HHSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.displayName,
                    style: hh.headline().copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: hh.footnote().copyWith(color: hh.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: HHSpacing.sm),
            Icon(LucideIcons.chevronRight, color: hh.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TokenEntry extends StatelessWidget {
  const _TokenEntry({
    required this.provider,
    required this.controller,
    required this.obscured,
    required this.errorMessage,
    required this.onToggleObscure,
    required this.onPaste,
    required this.onSubmit,
    required this.hh,
  });

  final ProviderId provider;
  final TextEditingController controller;
  final bool obscured;
  final String? errorMessage;
  final VoidCallback onToggleObscure;
  final VoidCallback onPaste;
  final VoidCallback onSubmit;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ProviderBadge(providerId: provider, showLabel: false, size: 24),
            const SizedBox(width: HHSpacing.sm),
            Text(
              '${provider.displayName} API Token',
              style: hh.headline().copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: HHSpacing.sm),
        Text(
          'HiveHub encrypts and stores your token locally using Android Keystore / iOS Keychain.',
          style: hh.footnote().copyWith(color: hh.textSecondary),
        ),
        const SizedBox(height: HHSpacing.lg),

        // Token input
        TextField(
          controller: controller,
          obscureText: obscured,
          style: hh.mono(),
          decoration: InputDecoration(
            hintText: 'Paste your ${provider.displayName} token',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: HHSpacing.md,
              vertical: HHSpacing.md,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    obscured ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 18,
                    color: hh.textTertiary,
                  ),
                  onPressed: onToggleObscure,
                ),
                IconButton(
                  icon: Icon(LucideIcons.clipboard, size: 18, color: hh.accent),
                  onPressed: onPaste,
                ),
              ],
            ),
          ),
        ),

        if (errorMessage != null) ...[
          const SizedBox(height: HHSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(HHSpacing.md),
            decoration: BoxDecoration(
              color: hh.statusFailed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hh.statusFailed.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  size: 16,
                  color: hh.statusFailed,
                ),
                const SizedBox(width: HHSpacing.sm),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: hh.subhead().copyWith(
                          color: hh.statusFailed,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: HHSpacing.xl),

        // Minting instructions
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(HHSpacing.md),
          decoration: BoxDecoration(
            color: hh.bgElevated2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hh.cardBorder.withValues(alpha: 0.6),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.helpCircle,
                    size: 14,
                    color: hh.textSecondary,
                  ),
                  const SizedBox(width: HHSpacing.xs),
                  Text(
                    'How to generate a token',
                    style: hh.caption().copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: HHSpacing.xs),
              Text(
                _mintingInstructions(provider),
                style: hh.footnote().copyWith(height: 1.45),
              ),
            ],
          ),
        ),

        const SizedBox(height: HHSpacing.xl),

        PrimaryButton(label: 'Connect', onTap: onSubmit),
        const SizedBox(height: HHSpacing.xxxl),
      ],
    );
  }

  static String _mintingInstructions(ProviderId id) => switch (id) {
        ProviderId.vercel =>
          '1. Go to vercel.com → Avatar → Settings → Tokens\n2. Click "Create Token"\n3. Scope: select your Team if your projects are under a team\n4. Copy and paste the full token here',
        ProviderId.netlify =>
          '1. Go to app.netlify.com → Avatar → User settings\n2. Navigate to Applications → Personal access tokens\n3. Click "New access token" and set an expiration\n4. Copy the generated token',
        ProviderId.cloudflarepages =>
          '1. Go to dash.cloudflare.com → My Profile → API Tokens\n2. Click "Create Token" → Custom token\n3. Permissions: Account · Cloudflare Pages · Read, Zone · DNS · Read\n4. Copy the token',
      };
}

class _ValidatingState extends StatelessWidget {
  const _ValidatingState({required this.hh});
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: HHSpacing.xxxl),
          const CupertinoActivityIndicator(radius: 16),
          const SizedBox(height: HHSpacing.lg),
          Text('Verifying token…', style: hh.body()),
          const SizedBox(height: HHSpacing.xxxl),
        ],
      ),
    );
  }
}

class _AccountPicker extends StatelessWidget {
  const _AccountPicker({
    required this.options,
    required this.onPick,
    required this.hh,
  });

  final List<AccountOption> options;
  final void Function(String id, String name) onPick;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Account or Team',
          style: hh.headline().copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: HHSpacing.xs),
        Text(
          'Multiple accounts or teams were found for this token. Which one would you like to link?',
          style: hh.body().copyWith(color: hh.textSecondary),
        ),
        const SizedBox(height: HHSpacing.lg),
        ...options.map((o) => Padding(
              padding: const EdgeInsets.only(bottom: HHSpacing.md),
              child: AppPressable(
                onTap: () {
                  HHHaptics.selectionClick();
                  onPick(o.id, o.name);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(HHSpacing.lg),
                  decoration: BoxDecoration(
                    color: hh.bgElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hh.cardBorder.withValues(alpha: 0.8),
                    ),
                    boxShadow: hh.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: hh.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          o.id.startsWith('team_')
                              ? LucideIcons.users
                              : LucideIcons.user,
                          color: hh.accent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: HHSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.name,
                              style: hh
                                  .headline()
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              o.id,
                              style: hh
                                  .footnote()
                                  .copyWith(color: hh.textTertiary),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        color: hh.textTertiary,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            )),
        const SizedBox(height: HHSpacing.xl),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({
    required this.controller,
    required this.onDone,
    required this.hh,
  });

  final TextEditingController controller;
  final VoidCallback onDone;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: hh.statusReady.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.check,
                color: hh.statusReady,
                size: 18,
              ),
            ),
            const SizedBox(width: HHSpacing.sm),
            Text(
              'Connected Successfully!',
              style: hh.headline().copyWith(
                    fontWeight: FontWeight.w700,
                    color: hh.statusReady,
                  ),
            ),
          ],
        ),
        const SizedBox(height: HHSpacing.sm),
        Text(
          'Customize the connection display name or keep the default.',
          style: hh.body().copyWith(color: hh.textSecondary),
        ),
        const SizedBox(height: HHSpacing.lg),
        TextField(
          controller: controller,
          style: hh.body(),
          decoration: const InputDecoration(
            hintText: 'e.g. My Vercel Production',
            contentPadding: EdgeInsets.symmetric(
              horizontal: HHSpacing.md,
              vertical: HHSpacing.md,
            ),
          ),
        ),
        const SizedBox(height: HHSpacing.xl),
        PrimaryButton(label: 'Done', onTap: onDone),
        const SizedBox(height: HHSpacing.xxxl),
      ],
    );
  }
}
