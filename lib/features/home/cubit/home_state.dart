import 'package:equatable/equatable.dart';
import 'package:gen_ui_poc/core/model/completed_quote_model.dart';

class HomeState extends Equatable {
  final List<CompletedQuote> completedQuotes;
  final bool isLoading;

  const HomeState({this.completedQuotes = const [], this.isLoading = false});

  HomeState copyWith({List<CompletedQuote>? completedQuotes, bool? isLoading}) {
    return HomeState(
      completedQuotes: completedQuotes ?? this.completedQuotes,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [completedQuotes, isLoading];
}
