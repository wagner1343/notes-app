import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:notes/core/models/note.dart';
import 'package:notes/core/utils/date_format.dart';
import 'package:notes/data/bloc/editor/editor_cubit.dart';
import 'package:notes/l10n/app_localizations.dart';

class NoteEditorPage extends StatelessWidget {
  const NoteEditorPage({super.key, this.note});

  final Note? note;

  static Route<Note?> route({Note? note}) {
    return MaterialPageRoute(builder: (_) => NoteEditorPage(note: note));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditorCubit(note: note),
      child: const _EditorView(),
    );
  }
}

class _EditorView extends StatefulWidget {
  const _EditorView();

  @override
  State<_EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<_EditorView> {
  late final _cubit = context.read<EditorCubit>();
  late final _titleController = TextEditingController(text: _cubit.state.title);
  late final _bodyController = TextEditingController(text: _cubit.state.body);
  final _bodyFocus = FocusNode();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  Future<void> _saveAndPop() async {
    if (!_cubit.state.hasContent) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 16),
            Text(l10n.savingChanges),
          ],
        ),
      ),
    );

    final saved = await _cubit.save(untitledLabel: l10n.untitled);
    messenger.hideCurrentSnackBar();
    if (mounted) Navigator.pop(context, saved);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _saveAndPop();
      },
      child: BlocBuilder<EditorCubit, EditorState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _saveAndPop,
              ),
              actions: [
                IconButton(
                  tooltip: state.isPinned ? l10n.unpin : l10n.pin,
                  icon: Icon(
                    state.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: state.isPinned ? scheme.primary : null,
                  ),
                  onPressed: _cubit.togglePin,
                ),
              ],
              bottom: PreferredSize(
                      preferredSize: Size.fromHeight(4),
                      child: state.isSaving
                          ? LinearProgressIndicator(minHeight: 4) : SizedBox.shrink(),
                    )
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                  child: TextField(
                    controller: _titleController,
                    autofocus: state.isNew,
                    textInputAction: TextInputAction.next,
                    onChanged: _cubit.titleChanged,
                    onSubmitted: (_) => _bodyFocus.requestFocus(),
                    style: theme.textTheme.headlineSmall,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: l10n.titleHint,
                      hintStyle: theme.textTheme.headlineSmall
                          ?.copyWith(color: scheme.outline),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: TextField(
                      controller: _bodyController,
                      focusNode: _bodyFocus,
                      onChanged: _cubit.bodyChanged,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: l10n.bodyHint,
                        hintStyle: theme.textTheme.bodyLarge
                            ?.copyWith(color: scheme.outline),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _BottomBar(state: state),
          );
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state});

  final EditorState state;

  String _status(BuildContext context, AppLocalizations l10n) {
    if (state.isSaving) return l10n.saving;
    if (state.updatedAt != null && !state.isNew) {
      return l10n.editedAt(formatClock(context, state.updatedAt!), state.charCount);
    }
    return l10n.charactersCount(state.charCount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return BottomAppBar(
      color: scheme.surface,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                _status(context, l10n),
                style:
                    theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
