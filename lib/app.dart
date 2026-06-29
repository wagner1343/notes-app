import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:notes/data/bloc/notes/notes_bloc.dart';
import 'package:notes/data/bloc/theme/theme_cubit.dart';
import 'package:notes/ui/theme/app_theme.dart';
import 'package:notes/data/notes/notes_repository.dart';
import 'package:notes/l10n/app_localizations.dart';
import 'package:notes/ui/notes_list/notes_list_page.dart';

class NotesApp extends StatelessWidget {
  const NotesApp({super.key, required this.repository});

  final NotesRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
            create: (_) => NotesBloc(repository)..add(const NotesRequested())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: mode,
            home: const NotesListPage(),
          );
        },
      ),
    );
  }
}
