import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/core/model/completed_quote_model.dart';
import 'package:gen_ui_poc/core/theme/app_theme.dart';
import 'package:gen_ui_poc/features/home/cubit/home_cubit.dart';
import 'package:gen_ui_poc/features/home/cubit/home_state.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final quotes = state.completedQuotes;
            return RefreshIndicator(
              color: AppTheme.textPrimary,
              onRefresh: () async => context.read<HomeCubit>().loadQuotes(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 124),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WorkspaceHeader(quotesCount: quotes.length),
                    const SizedBox(height: 28),
                    _HeroIntro(quotesCount: quotes.length),
                    const SizedBox(height: 34),
                    _SectionHeader(
                      title: 'Polizze attive',
                      trailing: quotes.isEmpty ? 'PRONTO' : 'AGGIORNATO OGGI',
                    ),
                    const SizedBox(height: 14),
                    ..._buildPolicyCards(quotes),
                    const SizedBox(height: 34),
                    const _SectionHeader(
                      title: 'Raccomandazioni',
                      trailing: 'PRIORITÀ',
                    ),
                    const SizedBox(height: 14),
                    ..._buildRecommendationCards(quotes),
                    const SizedBox(height: 34),
                    const _SupportCallout(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildPolicyCards(List<CompletedQuote> quotes) {
    final visibleQuotes = quotes.take(4).toList();
    if (visibleQuotes.isEmpty) {
      const placeholders = [
        (Icons.directions_car_rounded, 'Auto', 'POLIZZA #AU-9021'),
        (Icons.home_rounded, 'Casa', 'POLIZZA #HM-4420'),
        (Icons.favorite_rounded, 'Vita', 'POLIZZA #LF-7811'),
        (Icons.flight_rounded, 'Viaggio', 'POLIZZA #TR-1005'),
      ];
      return placeholders
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PolicyCard(
                icon: entry.$1,
                title: entry.$2,
                subtitle: entry.$3,
              ),
            ),
          )
          .toList();
    }

    return visibleQuotes
        .map(
          (quote) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PolicyCard(
              icon: _policyIconForQuote(quote),
              title: quote.vehicleLabel,
              subtitle: 'POLIZZA #${quote.id.substring(0, 8).toUpperCase()}',
              caption: '€ ${quote.totalPrice.toStringAsFixed(0)}/anno',
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildRecommendationCards(List<CompletedQuote> quotes) {
    final recommendations = <({IconData icon, String body, String cta})>[
      (
        icon: Icons.info,
        body: quotes.isNotEmpty
            ? 'La tua polizza più recente è disponibile per la revisione. Controlla il premio e conferma le protezioni che vuoi mantenere attive.'
            : 'Il tuo archivio assicurativo è ancora vuoto. Inizia con un preventivo auto o viaggio per creare il tuo primo workspace attivo.',
        cta: quotes.isNotEmpty ? 'Rivedi polizza' : 'Crea il primo preventivo',
      ),
      (
        icon: Icons.tips_and_updates_rounded,
        body:
            'In base alla tua attività potresti beneficiare di una strategia bundle che tiene la gestione delle coperture in un unico posto.',
        cta: 'Vedi dettagli bundle',
      ),
    ];

    return recommendations
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _RecommendationCard(
              icon: item.icon,
              body: item.body,
              cta: item.cta,
            ),
          ),
        )
        .toList();
  }

  IconData _policyIconForQuote(CompletedQuote quote) {
    final lower = quote.vehicleLabel.toLowerCase();
    if (lower.contains('viaggio')) {
      return Icons.flight_rounded;
    }
    if (lower.contains('vita')) {
      return Icons.favorite_rounded;
    }
    if (lower.contains('home') || lower.contains('casa')) {
      return Icons.home_rounded;
    }
    return Icons.directions_car_rounded;
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({required this.quotesCount});

  final int quotesCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.accentSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person_rounded, size: 16),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Workspace Assistente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => context.pushNamed('debug_logs'),
          icon: const Icon(Icons.bug_report_outlined, size: 18),
          tooltip: 'Debug logs',
        ),
        if (quotesCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$quotesCount ATTIVE',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ),
        const SizedBox(width: 10),
        const Icon(Icons.notifications, size: 18),
      ],
    );
  }
}

class _HeroIntro extends StatelessWidget {
  const _HeroIntro({required this.quotesCount});

  final int quotesCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ciao, curator.', style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 14),
        Text(
          quotesCount == 0
              ? 'Il tuo archivio assicurativo digitale è pronto. Inizia un preventivo per costruire il tuo primo workspace attivo.'
              : 'Il tuo archivio assicurativo digitale è aggiornato. Al momento hai $quotesCount polizz${quotesCount == 1 ? 'a attiva' : 'e attive'} disponibili per la revisione.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        Text(trailing, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.caption,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 42),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 0.8,
              color: AppTheme.textTertiary,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 10),
            Text(
              caption!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.icon,
    required this.body,
    required this.cta,
  });

  final IconData icon;
  final String body;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(body, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 10),
                Text(
                  cta,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCallout extends StatelessWidget {
  const _SupportCallout();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(
            'Domande sulla tua copertura?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 14),
          Text(
            'I nostri curator sono disponibili 24/7 per aiutarti a navigare polizze e sinistri.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Hai bisogno di aiuto?'),
          ),
        ],
      ),
    );
  }
}
