import 'package:flutter/material.dart';

import 'package:notes/core/models/note.dart';
import 'package:notes/core/utils/date_format.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.highlight,
    this.selected = false,
    this.selectionMode = false,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? highlight;
  final bool selected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainer,
      borderRadius: selected ? null : BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      shape: selected
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.primary, width: 2),
            )
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _highlighted(
                      note.title,
                      maxLines: 1,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _highlighted(
                      note.snippet,
                      maxLines: 2,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatTimestamp(context, note.updatedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (note.isPinned)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(Icons.push_pin, size: 18, color: scheme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlighted(String text,
      {required TextStyle? style, required int maxLines}) {
    final query = highlight?.trim();
    if (query == null || query.isEmpty) {
      return Text(text,
          style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    return Builder(builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      final spans = <TextSpan>[];
      final lowerText = text.toLowerCase();
      final lowerQuery = query.toLowerCase();
      var start = 0;

      while (true) {
        final i = lowerText.indexOf(lowerQuery, start);
        if (i < 0) {
          spans.add(TextSpan(text: text.substring(start)));
          break;
        }
        if (i > start) spans.add(TextSpan(text: text.substring(start, i)));
        spans.add(TextSpan(
          text: text.substring(i, i + query.length),
          style: TextStyle(
            backgroundColor: scheme.primaryContainer,
            color: scheme.onPrimaryContainer,
          ),
        ));
        start = i + query.length;
      }

      return Text.rich(
        TextSpan(style: style, children: spans),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    });
  }

}
