import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:notes/data/bloc/notes/notes_bloc.dart';
import 'package:notes/data/bloc/search/search_cubit.dart';
import 'package:notes/infra/di/injection.dart';
import 'package:notes/l10n/app_localizations.dart';
import 'package:notes/core/models/note.dart';
import 'package:notes/ui/editor/note_editor_page.dart';
import 'package:notes/ui/notes_list/widgets/note_card.dart';

class NotesSearchPage extends StatefulWidget {
  const NotesSearchPage({super.key});

  static Route<void> route(NotesBloc bloc) {
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: bloc),
          BlocProvider(create: (_) => getIt<SearchCubit>()..load()),
        ],
        child: const NotesSearchPage(),
      ),
    );
  }

  @override
  State<NotesSearchPage> createState() => _NotesSearchPageState();
}

class _NotesSearchPageState extends State<NotesSearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  var _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Note> _matches(List<Note> notes) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.body.toLowerCase().contains(q))
        .toList();
  }

  void _runSearch(String term) {
    _controller.text = term;
    _controller.selection = TextSelection.collapsed(offset: term.length);
    setState(() => _query = term);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final notes = context.watch<NotesBloc>().state.notes;
    final results = _matches(notes);
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Material(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          textInputAction: TextInputAction.search,
                          onChanged: (v) => setState(() => _query = v),
                          onSubmitted: (v) =>
                              context.read<SearchCubit>().record(v),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: l10n.searchHint,
                          ),
                        ),
                      ),
                      if (searching)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (searching)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.resultsCount(results.length),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.outline),
                  ),
                ),
              ),
            Expanded(
              child: searching
                  ? _results(results)
                  : _recentSearches(theme, scheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _results(List<Note> results) {
    if (results.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: Text(
          AppLocalizations.of(context).noMatches,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final note = results[index];
        return NoteCard(
          note: note,
          highlight: _query,
          onTap: () {
            context.read<SearchCubit>().record(_query);
            Navigator.push(context, NoteEditorPage.route(note: note));
          },
        );
      },
    );
  }

  Widget _recentSearches(ThemeData theme, ColorScheme scheme) {
    final l10n = AppLocalizations.of(context);
    final recent = context.watch<SearchCubit>().state;
    if (recent.isEmpty) return const SizedBox.shrink();

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            l10n.sectionRecent,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: scheme.outline,
            ),
          ),
        ),
        for (final term in recent)
          ListTile(
            leading: Icon(Icons.history, color: scheme.onSurfaceVariant),
            title: Text(term),
            trailing: IconButton(
              tooltip: l10n.remove,
              icon: Icon(Icons.close, size: 18, color: scheme.outline),
              onPressed: () => context.read<SearchCubit>().remove(term),
            ),
            onTap: () => _runSearch(term),
          ),
      ],
    );
  }
}
