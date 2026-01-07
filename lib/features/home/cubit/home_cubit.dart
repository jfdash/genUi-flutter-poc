import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/core/navigator/navigator_repository.dart';
import 'package:gen_ui_poc/features/home/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.navigatorRepository}) : super(HomeState());

  final NavigatorRepository navigatorRepository;

  Future<void> onInit() async {}
}
