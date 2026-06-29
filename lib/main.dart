import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'package:notes/app.dart';
import 'package:notes/infra/di/injection.dart';
import 'package:notes/data/notes/notes_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  await configureDependencies();

  runApp(NotesApp(repository: getIt<NotesRepository>()));
}
