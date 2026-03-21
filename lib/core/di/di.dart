import 'package:gen_ui_poc/core/navigator/navigator_repository.dart';
import 'package:gen_ui_poc/core/navigator/navigator_repository_impl.dart';
import 'package:gen_ui_poc/core/router/app_router.dart';
import 'package:gen_ui_poc/core/service/quote_storage_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt injector = GetIt.instance;

Future<void> registerDependencies() async {
  injector.registerSingleton<NavigatorRepository>(NavigatorRepositoryImpl(appRouter));

  injector.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  injector.registerSingleton<QuoteStorageRepository>(QuoteStorageRepository());
}

NavigatorRepository get navigatorRepository => injector<NavigatorRepository>();

SupabaseClient get supabaseClient => injector<SupabaseClient>();

QuoteStorageRepository get quoteStorageRepository => injector<QuoteStorageRepository>();
