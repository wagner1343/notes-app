import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:notes/data/bloc/notes/notes_bloc.dart';
import 'package:notes/data/bloc/theme/theme_cubit.dart';
import 'package:notes/l10n/app_localizations.dart';
import 'package:notes/core/models/note.dart';
import 'package:notes/ui/editor/note_editor_page.dart';
import 'package:notes/ui/search/notes_search_page.dart';
import 'package:notes/ui/widgets/delete_dialog.dart';
import 'package:notes/ui/notes_list/widgets/list_status_views.dart';
import 'package:notes/ui/notes_list/widgets/note_card.dart';
import 'package:notes/ui/notes_list/widgets/skeleton_card.dart';

class NotesListPage extends StatelessWidget {
  const NotesListPage({super.key});

  void _openSearch(BuildContext context) {
    Navigator.push(context, NotesSearchPage.route(context.read<NotesBloc>()));
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final state = context.watch<NotesBloc>().state;
    final selecting = state.isSelecting;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.read<NotesBloc>().add(const SelectionCleared());
      },
      child: Scaffold(
        appBar: selecting
            ? _selectionAppBar(context, state, l10n)
            : _defaultAppBar(context, themeCubit, l10n),
        body: _body(context, state),
        floatingActionButton: selecting || state.status == NotesStatus.failure
            ? null
            : FloatingActionButton.extended(
                icon: const Icon(Icons.edit),
                label: Text(l10n.newNote),
                onPressed: () => _openEditor(context, null),
              ),
      ),
    );
  }

  AppBar _defaultAppBar(
    BuildContext context,
    ThemeCubit themeCubit,
    AppLocalizations l10n,
  ) {
    return AppBar(
      title: Text(l10n.appTitle),
      actions: [
        IconButton(
          tooltip: l10n.searchTooltip,
          icon: const Icon(Icons.search),
          onPressed: () => _openSearch(context),
        ),
        IconButton(
          tooltip: l10n.toggleThemeTooltip,
          icon: Icon(themeCubit.isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: themeCubit.toggle,
        ),
      ],
    );
  }

  AppBar _selectionAppBar(
    BuildContext context,
    NotesState state,
    AppLocalizations l10n,
  ) {
    final bloc = context.read<NotesBloc>();
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: scheme.secondaryContainer,
      leading: IconButton(
        tooltip: l10n.cancel,
        icon: const Icon(Icons.close),
        onPressed: () => bloc.add(const SelectionCleared()),
      ),
      title: Text(l10n.selectedCount(state.selectedIds.length)),
      actions: [
        IconButton(
          tooltip: state.allSelected ? l10n.deselectAll : l10n.selectAll,
          icon: Icon(state.allSelected ? Icons.deselect : Icons.select_all),
          onPressed: () => bloc.add(const SelectAllToggled()),
        ),
        IconButton(
          tooltip: l10n.delete,
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteSelected(context, state.selectedIds.length),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, NotesState state) {
    switch (state.status) {
      case NotesStatus.loading:
        return const SkeletonList();
      case NotesStatus.failure:
        return ErrorNotesView(
          error: state.errorMessage ?? 'Unknown error',
          onRetry: () => context.read<NotesBloc>().add(const NotesRequested()),
        );
      case NotesStatus.success:
        if (state.isEmpty) return const EmptyNotesView();
        return _NotesBody(state: state);
    }
  }
}

Future<void> _openEditor(BuildContext context, Note? note) async {
  final bloc = context.read<NotesBloc>();
  final saved = await Navigator.push(context, NoteEditorPage.route(note: note));
  if (saved != null) bloc.add(NoteUpserted(saved));
}

Future<void> _deleteSelected(BuildContext context, int count) async {
  final bloc = context.read<NotesBloc>();
  final confirmed = await showDeleteNotesDialog(context, count: count);
  if (confirmed) bloc.add(const SelectedNotesDeleted());
}

class _NotesBody extends StatelessWidget {
  const _NotesBody({required this.state});

  final NotesState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final pinned = state.pinned;
    final others = state.others;

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        if (pinned.isNotEmpty) ...[
          SectionHeader(label: l10n.sectionPinned),
          for (final note in pinned) _card(context, note),
        ],
        if (others.isNotEmpty) ...[
          SectionHeader(
            label: l10n.sectionOthers,
            color: pinned.isEmpty ? scheme.primary : scheme.outline,
          ),
          for (final note in others) _card(context, note),
        ],
      ],
    );
  }

  Widget _card(BuildContext context, Note note) {
    final selecting = state.isSelecting;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: NoteCard(
        note: note,
        selectionMode: selecting,
        selected: state.isSelected(note.id),
        onTap: selecting
            ? () => _toggleSelection(context, note)
            : () => _openEditor(context, note),
        onLongPress: () => _toggleSelection(context, note),
      ),
    );
  }

  void _toggleSelection(BuildContext context, Note note) {
    if (note.id == null) return;
    context.read<NotesBloc>().add(NoteSelectionToggled(note.id!));
  }
}
