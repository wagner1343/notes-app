import 'package:flutter/material.dart';

import 'package:notes/l10n/app_localizations.dart';

class _CenteredStatus extends StatelessWidget {
  const _CenteredStatus({
    required this.icon,
    required this.tileColor,
    required this.iconColor,
    required this.heading,
    required this.body,
    this.action,
  });

  final IconData icon;
  final Color tileColor;
  final Color iconColor;
  final String heading;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(icon, size: 50, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(
              heading,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyNotesView extends StatelessWidget {
  const EmptyNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return _CenteredStatus(
      icon: Icons.edit_note,
      tileColor: scheme.primaryContainer,
      iconColor: scheme.primary,
      heading: l10n.emptyTitle,
      body: l10n.emptyBody,
    );
  }
}

class ErrorNotesView extends StatelessWidget {
  const ErrorNotesView({super.key, required this.onRetry, required this.error});

  final VoidCallback onRetry;
  final String error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return _CenteredStatus(
      icon: Icons.cloud_off,
      tileColor: scheme.errorContainer,
      iconColor: scheme.error,
      heading: l10n.errorTitle,
      body: '${l10n.errorBody}\n$error',
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: Text(l10n.tryAgain),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: color ?? theme.colorScheme.primary,
        ),
      ),
    );
  }
}
