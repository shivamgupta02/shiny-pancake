import 'package:get_it/get_it.dart';

import '../../data/datasources/local_database.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../services/backup_service.dart';
import '../../services/database_service.dart';
import '../../services/export_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/sms_parsing_service.dart';
import '../../services/sms_reader_service.dart';
import '../../services/sms_rule_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Database Service (singleton)
  final databaseService = DatabaseService();
  await databaseService.initialize();
  getIt.registerSingleton<DatabaseService>(databaseService);

  // Data Source (singleton)
  getIt.registerSingleton<LocalDatabase>(
    LocalDatabase(databaseService),
  );

  // Repositories (lazy singletons)
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepository(getIt<LocalDatabase>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<LocalDatabase>()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(getIt<LocalDatabase>()),
  );

  // Services (lazy singletons)
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
  getIt.registerLazySingleton<ExportService>(
    () => ExportService(),
  );
  getIt.registerLazySingleton<SmsParsingService>(
    () => SmsParsingService(),
  );
  getIt.registerLazySingleton<SmsReaderService>(
    () => SmsReaderService(),
  );
  getIt.registerLazySingleton<SmsRuleService>(
    () => SmsRuleService(),
  );
  getIt.registerLazySingleton<BackupService>(
    () => BackupService(
      expenseRepository: getIt<ExpenseRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
      settingsRepository: getIt<SettingsRepository>(),
      databaseService: getIt<DatabaseService>(),
    ),
  );
}
