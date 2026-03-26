import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:gen_ui_poc/core/logging/genui_log_entry.dart';
import 'package:gen_ui_poc/core/logging/genui_log_store.dart';
import 'package:gen_ui_poc/core/logging/genui_logger.dart';
import 'package:gen_ui_poc/core/service/ai_service.dart';
import 'package:gen_ui_poc/core/theme/app_theme.dart';

class DebugLogScreen extends StatefulWidget {
  const DebugLogScreen({super.key});

  @override
  State<DebugLogScreen> createState() => _DebugLogScreenState();
}

class _DebugLogScreenState extends State<DebugLogScreen> {
  final TextEditingController _searchController = TextEditingController();
  GenUiLogScope? _selectedScope;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GenUiLogStore>();
    final aiService = context.watch<AIServiceEventDriven>();
    final entries = store.entries.where(_matchesFilters).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F0E8),
        surfaceTintColor: Colors.transparent,
        title: const Text('GenUI Debug Logs'),
        actions: [
          IconButton(
            tooltip: 'Copy visible logs',
            onPressed: entries.isEmpty ? null : () => _copyEntries(entries),
            icon: const Icon(Icons.copy_all_rounded),
          ),
          IconButton(
            tooltip: 'Clear logs',
            onPressed: store.entries.isEmpty ? null : store.clear,
            icon: const Icon(Icons.delete_sweep_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value.trim()),
                    decoration: InputDecoration(
                      hintText: 'Filtra per testo, scope o payload',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _ScopeChip(
                          label: 'ALL',
                          selected: _selectedScope == null,
                          color: AppTheme.textPrimary,
                          onTap: () => setState(() => _selectedScope = null),
                        ),
                        ...GenUiLogScope.values.map(
                          (scope) => _ScopeChip(
                            label: scope.name.toUpperCase(),
                            selected: _selectedScope == scope,
                            color: _colorFor(scope),
                            onTap: () => setState(() {
                              _selectedScope =
                                  _selectedScope == scope ? null : scope;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatsCard(label: 'Visible', value: '${entries.length}'),
                      const SizedBox(width: 10),
                      _StatsCard(
                        label: 'Stored',
                        value: '${store.entries.length}',
                      ),
                    ],
                  ),
                  if (aiService.lastSurfaceSnapshot != null) ...[
                    const SizedBox(height: 12),
                    _SurfaceSnapshotCard(
                      snapshot: aiService.lastSurfaceSnapshot!,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: entries.isEmpty
                  ? const Center(
                      child: Text('Nessun log disponibile con i filtri correnti.'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return _LogCard(
                          entry: entry,
                          onTap: () => _showEntryDetail(entry),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilters(GenUiLogEntry entry) {
    if (_selectedScope != null && entry.scope != _selectedScope) {
      return false;
    }
    if (_query.isEmpty) {
      return true;
    }

    final payload = entry.data == null ? '' : jsonEncode(entry.data);
    final haystack =
        '${entry.scope.name} ${entry.message} $payload'.toLowerCase();
    return haystack.contains(_query.toLowerCase());
  }

  Future<void> _copyEntries(List<GenUiLogEntry> entries) async {
    final text = const JsonEncoder.withIndent('  ').convert(
      entries
          .map(
            (entry) => {
              'timestamp': entry.timestamp.toIso8601String(),
              'scope': entry.scope.name,
              'message': entry.message,
              'data': entry.data,
            },
          )
          .toList(),
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log copiati negli appunti')),
    );
  }

  void _showEntryDetail(GenUiLogEntry entry) {
    final payload = entry.data == null
        ? null
        : const JsonEncoder.withIndent('  ').convert(entry.data);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ScopeBadge(entry: entry),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('HH:mm:ss.SSS').format(entry.timestamp),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  entry.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (payload != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 420),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF030712),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        payload,
                        style: const TextStyle(
                          color: Color(0xFFD1FAE5),
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _colorFor(GenUiLogScope scope) {
    return GenUiLogEntry(
      timestamp: DateTime.now(),
      scope: scope,
      message: '',
    ).color;
  }
}

class _SurfaceSnapshotCard extends StatelessWidget {
  const _SurfaceSnapshotCard({required this.snapshot});

  final Map<String, Object?> snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAST SURFACE SNAPSHOT',
            style: TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            const JsonEncoder.withIndent('  ').convert(snapshot),
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        onSelected: (_) => onTap(),
        label: Text(label),
        labelStyle: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        selectedColor: color,
        backgroundColor: color.withValues(alpha: 0.10),
        side: BorderSide(color: color.withValues(alpha: 0.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  const _LogCard({required this.entry, required this.onTap});

  final GenUiLogEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: entry.color.withValues(alpha: 0.24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScopeBadge(entry: entry),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('HH:mm:ss').format(entry.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              if (entry.data != null && entry.data!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: entry.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    const JsonEncoder.withIndent('  ').convert(entry.data),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeBadge extends StatelessWidget {
  const _ScopeBadge({required this.entry});

  final GenUiLogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: entry.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        entry.scopeLabel,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}
