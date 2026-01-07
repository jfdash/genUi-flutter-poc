// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/core/di/di.dart';
import 'package:gen_ui_poc/core/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:gen_ui_poc/core/service/ai_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gen_ui_poc/features/quote/services/coverage_calculator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await registerDependencies();

  // Load .env
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('app_state');
  await Hive.openBox('conversation');

  runApp(const InsuranceApp());
}

class InsuranceApp extends StatefulWidget {
  const InsuranceApp({super.key});

  @override
  State<InsuranceApp> createState() => _InsuranceAppState();
}

class _InsuranceAppState extends State<InsuranceApp> {
  late final AIService _aiService;

  @override
  void initState() {
    super.initState();
    _aiService = AIService();
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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5),
            brightness: Brightness.light,
          ),
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        ),
      ),
    );
  }
}