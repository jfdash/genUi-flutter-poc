import 'package:flutter/material.dart';
import 'package:gen_ui_poc/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'navigator_repository.dart';

class NavigatorRepositoryImpl implements NavigatorRepository {
  NavigatorRepositoryImpl(this._router);

  @protected
  bool isLoaderShown = false;
  final GoRouter _router;

  Future<void> _pushLoader(Widget child) async {
    if (!isLoaderShown) {
      isLoaderShown = true;
      await _pushOverlay(child: PopScope(canPop: false, child: child), barrierDismissible: false);
    }
  }

  void _popLoader() {
    if (isLoaderShown) {
      isLoaderShown = false;
      _router.pop();
    }
  }

  @override
  Future<void> showLoader() async {
    await _pushLoader(
      const CircularProgressIndicator(
        color: AppTheme.primaryBlue,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  @override
  Future<void> hideLoader() async {
    _popLoader();
  }

  @override
  Future<T> pushToRoute<T>(String route, {Map<String, dynamic>? params}) async {
    _router.go(route, extra: params);
    return Future.value();
  }

  @override
  Future<void> replaceRoute(String route) async {
    // Use replace to properly replace the current route in history
    _router.replace(route);
  }

  @override
  Future<void> goBack<T>({T? result, Map<String, dynamic>? extra}) async {
    _router.pop(result);
  }

  @override
  Future<void> pushReplacementRoute(String route, {Map<String, dynamic>? params}) async {
    // Use replace to clear the current route from history
    _router.replace(route, extra: params);
  }

  @override
  String getCurrentRoute() {
    return _router.routerDelegate.currentConfiguration.uri.path;
  }

  Future<T> _pushOverlay<T extends Object?>({
    required Widget child,
    bool barrierDismissible = false,
    Color? barrierColor = const Color.fromRGBO(23, 24, 26, 0.60),
  }) async {
    final context = _router.routerDelegate.navigatorKey.currentContext!;
    final result = await showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => SizedBox(width: 600, child: Center(child: child)),
    );
    return Future.value(result);
  }

  @override
  Future<T> openDialog<T>(Widget dialog, {bool barrierDismissible = true}) async {
    return await _pushOverlay(
      child: dialog,
      barrierDismissible: barrierDismissible,
      barrierColor: const Color.fromRGBO(23, 24, 26, 0.60),
    );
  }

  @override
  Future<void> closeDialogAndPushToRoute(String route, {Map<String, dynamic>? params}) async {
    final context = _router.routerDelegate.navigatorKey.currentContext!;
    if (context.canPop()) {
      context.pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pushToRoute<void>(route, params: params);
      });
    }
  }

  @override
  List<String> get currentStack {
    return [_router.routerDelegate.currentConfiguration.uri.path];
  }
}
