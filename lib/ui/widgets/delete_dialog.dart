import 'package:flutter/material.dart';

import 'package:notes/l10n/app_localizations.dart';

Future<bool> showDeleteNoteDialog(
  BuildContext context, {
  required String title,
}) {
  final l10n = AppLocalizations.of(context);
  final name = title.isEmpty ? l10n.untitled : title;
  return _confirmDelete(
    context,
    title: l10n.deleteNoteTitle,
    message: l10n.deleteNoteMessage(name),
  );
}

Future<bool> showDeleteNotesDialog(BuildContext context, {required int count}) {
  final l10n = AppLocalizations.of(context);
  return _confirmDelete(
    context,
    title: l10n.deleteNotesTitle(count),
    message: l10n.deleteNotesMessage(count),
  );
}

Future<bool> _confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final scheme = Theme.of(context).colorScheme;

  final result = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x731C1B1F),
    builder: (context) {
      final theme = Theme.of(context);
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        icon: Icon(Icons.delete, color: scheme.primary),
        title: Text(title),
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: scheme.error),
            child: Text(l10n.delete),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
