import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/core/di/di.dart';
import 'package:gen_ui_poc/features/home/cubit/home_cubit.dart';
import 'package:gen_ui_poc/features/home/home_screen.dart';
import 'package:gen_ui_poc/features/quote/quote_chat_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
  
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => BlocProvider(
        create: (context) => HomeCubit(navigatorRepository: navigatorRepository)..onInit(),
        child: const HomeScreen(),
      ),
    ),
    // Add other routes here
    GoRoute(
      path: '/quote_chat',
      name: 'quote_chat',
      builder: (context, state) => const QuoteChatScreen(), // Replace with actual QuoteChat
    ),
  ],
);
