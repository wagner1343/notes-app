import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:notes/data/database/app_database.dart';
import 'package:notes/infra/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() => getIt.init();

@module
abstract class RegisterModule {
  @preResolve
  @singleton
  Future<AppDatabase> appDatabase() => AppDatabase.open();
}
