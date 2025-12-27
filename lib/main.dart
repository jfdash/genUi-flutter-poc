import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gen_ui_poc/home_page_screen.dart';
import 'package:gen_ui_poc/service/ai_service.dart';
import 'package:gen_ui_poc/widgets/chat_message_widget.dart';
import 'package:gen_ui_poc/widgets/custom_bottom_navbar_widget.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await dotenv.load(fileName: ".env");

  runApp(ChangeNotifierProvider(create: (_) => AIService(), child: const InsuranceApp()));
}

class InsuranceApp extends StatelessWidget {
  const InsuranceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covera - Assicurazioni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    if (index == 2) {
      // Assistenza tab -> Open Chat
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
    } else {
      setState(() => _currentIndex = index);
    }
  }

  void _openChat() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ChatScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onAssistantTap: _openChat),
          const _PlaceholderScreen(title: 'Sinistri', icon: Icons.receipt_long_rounded),
          const SizedBox(), // Chat opens as modal
          const _PlaceholderScreen(title: 'Shop', icon: Icons.shopping_bag_rounded),
          const _PlaceholderScreen(title: 'Altro', icon: Icons.grid_view_rounded),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: _currentIndex, onTap: _onNavTap),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text('Coming soon', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
