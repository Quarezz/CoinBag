import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/repositories/auth/auth_repository.dart';
import '../domain/repositories/auth/auth_repository_impl.dart';
import '../domain/repositories/dashboard/dashboard_repository.dart';
import '../domain/repositories/dashboard/dashboard_repository_impl.dart';
import '../domain/repositories/account/account_repository.dart';
import '../domain/repositories/account/account_repository_impl.dart';
import '../domain/repositories/expense/expense_repository.dart';
import '../domain/repositories/expense/expense_repository_impl.dart';
import '../domain/repositories/categories/category_repository.dart';
import '../domain/repositories/categories/category_repository_impl.dart';
import '../gateway/network_data_source.dart';
import '../gateway/supabase/supabase_network_data_source.dart';
import '../domain/services/iap_service.dart';
import '../domain/services/bank_sync_service.dart';
import '../domain/repositories/tags/tag_repository.dart';
import '../domain/repositories/tags/tag_repository_impl.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Supabase
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Network Data Source
  getIt.registerLazySingleton<NetworkDataSource>(
    () => SupabaseNetworkDataSource(getIt<SupabaseClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<NetworkDataSource>()),
  );
  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(getIt<NetworkDataSource>()),
  );
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(getIt<NetworkDataSource>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      getIt<NetworkDataSource>(),
      getIt<AuthRepository>(),
    ),
  );
  getIt.registerLazySingleton<TagRepository>(
    () => TagRepositoryImpl(getIt<NetworkDataSource>()),
  );

  // Services
  getIt.registerLazySingleton<IapService>(() => IapService());
  getIt.registerLazySingleton<BankSyncService>(
    () => BankSyncService(iapService: getIt<IapService>()),
  );
}
