import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:notes/l10n/app_localizations.dart';

String formatTimestamp(BuildContext context, DateTime time) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toString();
  final now = DateTime.now();
  final diff = now.difference(time);

  if (diff.inMinutes < 1) return l10n.justNow;
  if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
  if (diff.inHours < 24 && now.day == time.day) {
    return l10n.hoursAgo(diff.inHours);
  }

  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (time.year == yesterday.year &&
      time.month == yesterday.month &&
      time.day == yesterday.day) {
    return l10n.yesterday;
  }

  if (time.year == now.year) return DateFormat.MMMd(locale).format(time);
  return DateFormat.yMMMd(locale).format(time);
}

String formatClock(BuildContext context, DateTime time) {
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.jm(locale).format(time);
}
