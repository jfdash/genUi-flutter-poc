// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/core/di/di.dart';
import 'package:gen_ui_poc/core/router/app_router.dart';
import 'package:gen_ui_poc/core/service/quote_storage_repository.dart';
import 'package:gen_ui_poc/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:gen_ui_poc/core/service/ai_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gen_ui_poc/features/quote/services/coverage_calculator.dart';
import 'package:genui/genui.dart';

// Logger globale per genui - mostra TUTTI i messaggi AI
final _genUiLogger = configureGenUiLogging();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configura il listener per i log di genui
  _genUiLogger.onRecord.listen((record) {
    debugPrint('🔍 [${record.loggerName}] ${record.message}');
  });

  await registerDependencies();

  // Load .env
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('app_state');
  await Hive.openBox('conversation');

  // Initialize QuoteStorageRepository
  await injector<QuoteStorageRepository>().init();

  runApp(const InsuranceApp());
}

class InsuranceApp extends StatefulWidget {
  const InsuranceApp({super.key});

  @override
  State<InsuranceApp> createState() => _InsuranceAppState();
}

class _InsuranceAppState extends State<InsuranceApp> {
  late final AIServiceEventDriven _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = AIServiceEventDriven();
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _aiService),
        RepositoryProvider(create: (_) => CoverageCalculator()),
      ],
      child: MaterialApp.router(
        title: 'Insurance GenUI POC',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
      ),
    );
  }
}
