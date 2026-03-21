import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/core/di/di.dart';
import 'package:gen_ui_poc/core/model/completed_quote_model.dart';
import 'package:gen_ui_poc/core/navigator/scaffold_with_nav_bar.dart';
import 'package:gen_ui_poc/features/home/cubit/home_cubit.dart';
import 'package:gen_ui_poc/features/home/home_screen.dart';
import 'package:gen_ui_poc/features/quote/quote_chat_screen.dart';
import 'package:gen_ui_poc/features/quote/widgets/quote_confirmation_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => BlocProvider(
                create: (context) => HomeCubit(
                  navigatorRepository: navigatorRepository,
                  quoteStorageRepository: quoteStorageRepository,
                )..onInit(),
                child: const HomeScreen(),
              ),
            ),
          ],
        ),
        // Tab 2: Chat Preventivo
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/quote_chat',
              name: 'quote_chat',
              builder: (context, state) => const QuoteChatScreenEventDriven(),
            ),
          ],
        ),
      ],
    ),
    // Confirmation screen (outside shell - no bottom nav)
    GoRoute(
      path: '/confirmation',
      name: 'confirmation',
      builder: (context, state) {
        final quote = state.extra as CompletedQuote;
        return QuoteConfirmationScreen(quote: quote);
      },
    ),
  ],
);
