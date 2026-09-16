import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_exception.dart';
import '../../models/connection.dart';
import '../../models/credential.dart';
import '../../models/registrar_id.dart';
import '../../providers/hosting/hosting_provider.dart';
import '../../providers/provider_registry.dart';
import '../../shared/haptics.dart';
import '../../shared/theme.dart';
import '../../shared/window_security.dart';
import '../../state/connections_notifier.dart';
import '../../state/domains_notifier.dart';
import '../../state/sites_notifier.dart';
import '../../widgets/app_pressable.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/provider_badge.dart';

class AddConnectionSheet extends ConsumerStatefulWidget {
  const AddConnectionSheet({super.key});

  @override
  ConsumerState<AddConnectionSheet> createState() => _AddConnectionSheetState();
}

enum _Step { pickCategory, pickProvider, enterToken, validating, pickAccount, nameIt }
enum _Category { hosting, registrar }

class _AddConnectionSheetState extends ConsumerState<AddConnectionSheet> {
  _Step _step = _Step.pickCategory;
  _Category _category = _Category.hosting;
  ProviderId? _hostingProvider;
  RegistrarId? _registrarProvider;

  String _token = '';
  String _secretKey = '';
  bool _tokenObscured = true;
  bool _secretObscured = true;

  List<AccountOption>? _accountOptions;
  String? _selectedAccountId;
  String? _errorMessage;
  String? _createdConnectionId;

  final _tokenController = TextEditingController();
  final _secretController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Enable FLAG_SECURE to prevent screenshots of tokens and secret keys
    WindowSecurity.setSecure(true);
  }

  @override
  void dispose() {
    WindowSecurity.setSecure(false);
    _tokenController.dispose();
    _secretController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _canGoBack =>
      _step != _Step.pickCategory &&
      _step != _Step.validating &&
      _step != _Step.nameIt;

  void _onBack() {
    setState(() {
      if (_step == _Step.pickAccount) {
        _step = _Step.enterToken;
      } else if (_step == _Step.enterToken) {
        _step = _Step.pickProvider;
      } else if (_step == _Step.pickProvider) {
        _step = _Step.pickCategory;
      }
      _errorMessage = null;
    });
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
                    if (_canGoBack)
                      Padding(
                        padding: const EdgeInsets.only(right: HHSpacing.sm),
                        child: AppPressable(
                          onTap: _onBack,
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
        _Step.pickCategory => 'Add Connection',
        _Step.pickProvider => _category == _Category.hosting
            ? 'Hosting Platform'
            : 'Domain Registrar',
        _Step.enterToken => 'Enter Credentials',
        _Step.validating => 'Verifying…',
        _Step.pickAccount => 'Choose Account',
        _Step.nameIt => 'Connection Details',
      };

  Widget _buildStep(HHTokens hh) {
    return switch (_step) {
      _Step.pickCategory => _CategoryPicker(
          onPick: _onCategoryPicked,
          hh: hh,
        ),
      _Step.pickProvider => _ProviderPicker(
          category: _category,
          onPickHosting: _onHostingPicked,
          onPickRegistrar: _onRegistrarPicked,
          hh: hh,
        ),
      _Step.enterToken => _CredentialsEntry(
          hostingProvider: _hostingProvider,
          registrarProvider: _registrarProvider,
          tokenController: _tokenController,
          secretController: _secretController,
          tokenObscured: _tokenObscured,
          secretObscured: _secretObscured,
          errorMessage: _errorMessage,
          onToggleTokenObscure: () =>
              setState(() => _tokenObscured = !_tokenObscured),
          onToggleSecretObscure: () =>
              setState(() => _secretObscured = !_secretObscured),
          onPasteToken: _pasteToken,
          onPasteSecret: _pasteSecret,
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

  void _onCategoryPicked(_Category cat) {
    setState(() {
      _category = cat;
      _step = _Step.pickProvider;
      _hostingProvider = null;
      _registrarProvider = null;
      _errorMessage = null;
    });
  }

  void _onHostingPicked(ProviderId p) {
    setState(() {
      _hostingProvider = p;
      _registrarProvider = null;
      _step = _Step.enterToken;
      _errorMessage = null;
      _tokenController.clear();
      _secretController.clear();
    });
  }

  void _onRegistrarPicked(RegistrarId r) {
    setState(() {
      _registrarProvider = r;
      _hostingProvider = null;
      _step = _Step.enterToken;
      _errorMessage = null;
      _tokenController.clear();
      _secretController.clear();
    });
  }

  Future<void> _pasteToken() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _tokenController.text = data!.text!.trim();
    }
  }

  Future<void> _pasteSecret() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _secretController.text = data!.text!.trim();
    }
  }

  Future<void> _validate() async {
    _token = _tokenController.text.trim();
    _secretKey = _secretController.text.trim();

    if (_category == _Category.hosting) {
      if (_token.isEmpty) {
        setState(() => _errorMessage = 'Please paste your API token above');
        return;
      }
      setState(() {
        _step = _Step.validating;
        _errorMessage = null;
      });

      final provider = providerFor(_hostingProvider!);
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

          await _createAndFinalizeHostingConnection(
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
    } else {
      // Registrar
      if (_registrarProvider == RegistrarId.porkbun) {
        if (_token.isEmpty || _secretKey.isEmpty) {
          setState(() =>
              _errorMessage = 'Please enter both API Key and Secret Key');
          return;
        }
      } else {
        if (_token.isEmpty) {
          setState(() => _errorMessage = 'Please paste your API token above');
          return;
        }
      }

      setState(() {
        _step = _Step.validating;
        _errorMessage = null;
      });

      final Credential cred = _registrarProvider == RegistrarId.porkbun
          ? KeyPairCredential(apiKey: _token, secretKey: _secretKey)
          : BearerCredential(token: _token);

      final result = await ref
          .read(connectionsProvider.notifier)
          .addRegistrarConnection(
            registrarId: _registrarProvider!,
            credential: cred,
          );

      result.when(
        ok: (conn) {
          _createdConnectionId = conn.id;
          _nameController.text = conn.displayName;
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
  }

  Future<void> _createAndFinalizeHostingConnection({
    String? selectedAccountId,
  }) async {
    final result = await ref.read(connectionsProvider.notifier).addConnection(
          providerId: _hostingProvider!,
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
    _createAndFinalizeHostingConnection(selectedAccountId: accountId);
  }

  Future<void> _save() async {
    HHHaptics.lightImpact();
    final customName = _nameController.text.trim();
    if (customName.isNotEmpty && _createdConnectionId != null) {
      await ref
          .read(connectionsProvider.notifier)
          .updateDisplayName(_createdConnectionId!, customName);
    }
    // Refresh feeds immediately
    ref.invalidate(sitesProvider);
    ref.invalidate(domainsProvider);
    if (mounted) Navigator.of(context).pop();
  }

  String _friendlyError(ApiException e) => switch (e) {
        UnauthorizedException() =>
          'Invalid credentials — check that you entered them correctly.',
        ForbiddenException() =>
          'Credentials lack required permissions. Check instructions below.',
        NotFoundException() => 'Account not found — verify your token scope.',
        RateLimitedException() => 'Rate limited — wait a moment and try again.',
        NetworkException() => 'Network connection error — check internet.',
        UnknownException() => e.message,
      };
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.onPick, required this.hh});
  final ValueChanged<_Category> onPick;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select the type of service you would like to connect to Hivetics.',
          style: hh.body().copyWith(color: hh.textSecondary),
        ),
        const SizedBox(height: HHSpacing.lg),
        _CategoryCard(
          icon: LucideIcons.server,
          title: 'Hosting Platform',
          subtitle: 'Vercel, Netlify, Cloudflare Pages',
          onTap: () {
            HHHaptics.selectionClick();
            onPick(_Category.hosting);
          },
          hh: hh,
        ),
        const SizedBox(height: HHSpacing.md),
        _CategoryCard(
          icon: LucideIcons.globe,
          title: 'Domain Registrar',
          subtitle: 'GoDaddy, Porkbun, Cloudflare Registrar',
          onTap: () {
            HHHaptics.selectionClick();
            onPick(_Category.registrar);
          },
          hh: hh,
        ),
        const SizedBox(height: HHSpacing.xl),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.hh,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: hh.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: hh.accent, size: 20),
            ),
            const SizedBox(width: HHSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: hh.headline().copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: hh.footnote().copyWith(color: hh.textSecondary),
                    maxLines: 1,
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

class _ProviderPicker extends StatelessWidget {
  const _ProviderPicker({
    required this.category,
    required this.onPickHosting,
    required this.onPickRegistrar,
    required this.hh,
  });

  final _Category category;
  final ValueChanged<ProviderId> onPickHosting;
  final ValueChanged<RegistrarId> onPickRegistrar;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    if (category == _Category.hosting) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select a hosting provider to link your deployments and sites.',
            style: hh.body().copyWith(color: hh.textSecondary),
          ),
          const SizedBox(height: HHSpacing.lg),
          ...ProviderId.values.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: HHSpacing.md),
                child: _HostingCard(
                  provider: p,
                  onPick: onPickHosting,
                  hh: hh,
                ),
              )),
          const SizedBox(height: HHSpacing.xl),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select a domain registrar to monitor expirations and DNS records.',
          style: hh.body().copyWith(color: hh.textSecondary),
        ),
        const SizedBox(height: HHSpacing.lg),
        ...RegistrarId.values.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: HHSpacing.md),
              child: _RegistrarCard(
                registrar: r,
                onPick: onPickRegistrar,
                hh: hh,
              ),
            )),
        const SizedBox(height: HHSpacing.xl),
      ],
    );
  }
}

class _HostingCard extends StatelessWidget {
  const _HostingCard({
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
      ProviderId.vercel => 'Frontend & serverless deploys',
      ProviderId.netlify => 'Web apps & custom domains',
      ProviderId.cloudflarepages => 'Edge hosting & preview branches',
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: hh.footnote().copyWith(color: hh.textSecondary),
                    maxLines: 1,
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

class _RegistrarCard extends StatelessWidget {
  const _RegistrarCard({
    required this.registrar,
    required this.onPick,
    required this.hh,
  });

  final RegistrarId registrar;
  final ValueChanged<RegistrarId> onPick;
  final HHTokens hh;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (registrar) {
      RegistrarId.godaddy => 'Domains & DNS management',
      RegistrarId.porkbun => 'Domains & DNS management',
      RegistrarId.cloudflareregistrar => 'Domains & DNS zones',
    };

    return AppPressable(
      onTap: () {
        HHHaptics.selectionClick();
        onPick(registrar);
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
            RegistrarBadge(registrarId: registrar, showLabel: false, size: 36),
            const SizedBox(width: HHSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    registrar.displayName,
                    style: hh.headline().copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: hh.footnote().copyWith(color: hh.textSecondary),
                    maxLines: 1,
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

class _CredentialsEntry extends StatelessWidget {
  const _CredentialsEntry({
    required this.hostingProvider,
    required this.registrarProvider,
    required this.tokenController,
    required this.secretController,
    required this.tokenObscured,
    required this.secretObscured,
    required this.errorMessage,
    required this.onToggleTokenObscure,
    required this.onToggleSecretObscure,
    required this.onPasteToken,
    required this.onPasteSecret,
    required this.onSubmit,
    required this.hh,
  });

  final ProviderId? hostingProvider;
  final RegistrarId? registrarProvider;
  final TextEditingController tokenController;
  final TextEditingController secretController;
  final bool tokenObscured;
  final bool secretObscured;
  final String? errorMessage;
  final VoidCallback onToggleTokenObscure;
  final VoidCallback onToggleSecretObscure;
  final VoidCallback onPasteToken;
  final VoidCallback onPasteSecret;
  final VoidCallback onSubmit;
  final HHTokens hh;

  bool get isPorkbun => registrarProvider == RegistrarId.porkbun;

  String get displayName => hostingProvider != null
      ? hostingProvider!.displayName
      : registrarProvider!.displayName;

  String get portalUrl => switch (hostingProvider) {
        ProviderId.vercel => 'https://vercel.com/account/tokens',
        ProviderId.netlify =>
          'https://app.netlify.com/user/applications#personal-access-tokens',
        ProviderId.cloudflarepages =>
          'https://dash.cloudflare.com/profile/api-tokens',
        null => switch (registrarProvider!) {
            RegistrarId.godaddy => 'https://developer.godaddy.com/keys',
            RegistrarId.porkbun => 'https://porkbun.com/account/api',
            RegistrarId.cloudflareregistrar =>
              'https://dash.cloudflare.com/profile/api-tokens',
          },
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (hostingProvider != null)
              ProviderBadge(
                providerId: hostingProvider!,
                showLabel: false,
                size: 24,
              )
            else
              RegistrarBadge(
                registrarId: registrarProvider!,
                showLabel: false,
                size: 24,
              ),
            const SizedBox(width: HHSpacing.sm),
            Expanded(
              child: Text(
                '$displayName Credentials',
                style: hh.headline().copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: HHSpacing.sm),
        Text(
          'Hivetics encrypts and stores credentials locally using Android Keystore. They never leave your device.',
          style: hh.footnote().copyWith(color: hh.textSecondary),
        ),
        const SizedBox(height: HHSpacing.lg),

        // Primary Field (Token or API Key)
        if (isPorkbun) ...[
          Text('API KEY', style: hh.caption2()),
          const SizedBox(height: HHSpacing.xs),
        ],
        TextField(
          controller: tokenController,
          obscureText: tokenObscured,
          style: hh.mono(),
          decoration: InputDecoration(
            hintText: isPorkbun ? 'Enter API Key (pk1_...)' : 'Paste your $displayName token',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: HHSpacing.md,
              vertical: HHSpacing.md,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    tokenObscured ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 18,
                    color: hh.textTertiary,
                  ),
                  onPressed: onToggleTokenObscure,
                ),
                IconButton(
                  icon: Icon(LucideIcons.clipboard, size: 18, color: hh.accent),
                  onPressed: onPasteToken,
                ),
              ],
            ),
          ),
        ),

        // Second Field (Secret Key for Porkbun)
        if (isPorkbun) ...[
          const SizedBox(height: HHSpacing.md),
          Text('SECRET API KEY', style: hh.caption2()),
          const SizedBox(height: HHSpacing.xs),
          TextField(
            controller: secretController,
            obscureText: secretObscured,
            style: hh.mono(),
            decoration: InputDecoration(
              hintText: 'Enter Secret API Key (sk1_...)',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: HHSpacing.md,
                vertical: HHSpacing.md,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      secretObscured ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 18,
                      color: hh.textTertiary,
                    ),
                    onPressed: onToggleSecretObscure,
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.clipboard, size: 18, color: hh.accent),
                    onPressed: onPasteSecret,
                  ),
                ],
              ),
            ),
          ),
        ],

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        'How to get credentials',
                        style: hh.caption().copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  AppPressable(
                    onTap: () => launchUrl(
                      Uri.parse(portalUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Open $displayName',
                          style: hh.caption().copyWith(
                                color: hh.accent,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(LucideIcons.externalLink, size: 12, color: hh.accent),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: HHSpacing.sm),
              Text(
                _mintingInstructions(),
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

  String _mintingInstructions() {
    if (hostingProvider != null) {
      return switch (hostingProvider!) {
        ProviderId.vercel =>
          '1. Go to vercel.com → Avatar → Settings → Tokens\n2. Click "Create Token"\n3. Scope: select your Team if your projects are under a team\n4. Copy and paste the full token here',
        ProviderId.netlify =>
          '1. Go to app.netlify.com → Avatar → User settings\n2. Navigate to Applications → Personal access tokens\n3. Click "New access token" and set an expiration\n4. Copy the generated token',
        ProviderId.cloudflarepages =>
          '1. Go to dash.cloudflare.com → My Profile → API Tokens\n2. Click "Create Token" → Custom token\n3. Add 4 permissions: Account·Account Settings·Read, Account·Cloudflare Pages·Read, Account·Registrar Domains·Read, Zone·DNS·Read (All zones)\n4. Copy the token\n\nThis one token also powers the Domains tab if you use Cloudflare Registrar.',
      };
    }

    return switch (registrarProvider!) {
      RegistrarId.godaddy =>
        '1. Go to developer.godaddy.com/keys\n2. Click "Create New API Key" (choose "Production") or generate a Personal Access Token (PAT)\n3. Copy the token and paste it above.\n\nNote: Requires at least 1 active domain in your GoDaddy account.',
      RegistrarId.porkbun =>
        '1. Go to porkbun.com/account/api\n2. Generate an API Key and API Secret\n3. In your Porkbun Domain Management list, ensure "API Access" is enabled for the domains you want visible here\n4. Paste both keys above',
      RegistrarId.cloudflareregistrar =>
        '1. Go to dash.cloudflare.com → My Profile → API Tokens\n2. Create a Custom Token with:\n   • Account · Registrar Domains · Read\n   • Account · Account Settings · Read\n   • Zone · DNS · Read\n3. Copy and paste the token above',
    };
  }
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
          Text('Verifying credentials…', style: hh.body()),
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
            hintText: 'e.g. My Production Domains',
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
