import 'dart:async';

import 'package:gen_ui_poc/core/model/completed_quote_model.dart';
import 'package:hive/hive.dart';

class QuoteStorageRepository {
  static const String _boxName = 'completed_quotes';

  Box? _box;

  final _changesController = StreamController<void>.broadcast();

  /// Stream che emette ogni volta che i preventivi cambiano (save/delete/clear)
  Stream<void> get onChanged => _changesController.stream;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  Box get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw StateError('QuoteStorageRepository not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Salva un preventivo completato
  Future<void> saveQuote(CompletedQuote quote) async {
    await _safeBox.put(quote.id, quote.toJsonString());
    _changesController.add(null);
  }

  /// Restituisce tutti i preventivi salvati, ordinati per data (più recente prima)
  List<CompletedQuote> getAllQuotes() {
    final quotes = <CompletedQuote>[];
    for (final key in _safeBox.keys) {
      try {
        final jsonString = _safeBox.get(key) as String;
        quotes.add(CompletedQuote.fromJsonString(jsonString));
      } catch (e) {
        // Skip corrupted entries
      }
    }
    quotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return quotes;
  }

  /// Elimina un preventivo
  Future<void> deleteQuote(String id) async {
    await _safeBox.delete(id);
    _changesController.add(null);
  }

  /// Elimina tutti i preventivi
  Future<void> clearAll() async {
    await _safeBox.clear();
    _changesController.add(null);
  }

  /// Numero di preventivi salvati
  int get count => _safeBox.length;
}
