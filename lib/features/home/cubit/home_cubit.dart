import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/core/navigator/navigator_repository.dart';
import 'package:gen_ui_poc/core/service/quote_storage_repository.dart';
import 'package:gen_ui_poc/features/home/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.navigatorRepository, required this.quoteStorageRepository})
    : super(const HomeState());

  final NavigatorRepository navigatorRepository;
  final QuoteStorageRepository quoteStorageRepository;
  StreamSubscription<void>? _storageSubscription;

  Future<void> onInit() async {
    loadQuotes();
    _storageSubscription = quoteStorageRepository.onChanged.listen((_) {
      loadQuotes();
    });
  }

  void loadQuotes() {
    emit(state.copyWith(isLoading: true));
    final quotes = quoteStorageRepository.getAllQuotes();
    emit(state.copyWith(completedQuotes: quotes, isLoading: false));
  }

  @override
  Future<void> close() {
    _storageSubscription?.cancel();
    return super.close();
  }
}
