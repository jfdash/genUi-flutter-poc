// navigator_repository.dart
import 'package:flutter/material.dart';

abstract class NavigatorRepository {
  void showLoader();

  void hideLoader();

  Future<T> pushToRoute<T>(String route, {Map<String, dynamic>? params});

  Future<void> replaceRoute(String route);

  Future<void> goBack<T>({T? result, Map<String, dynamic>? extra});

  Future<void> pushReplacementRoute(String route, {Map<String, dynamic>? params});

  String getCurrentRoute();

  Future<T> openDialog<T>(Widget dialog, {bool barrierDismissible = true});

  Future<void> closeDialogAndPushToRoute(String route, {Map<String, dynamic>? params});

  List<String> get currentStack;
}
