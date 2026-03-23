import 'package:flutter/material.dart';
import 'package:gen_ui_poc/core/model/completed_quote_model.dart';
import 'package:gen_ui_poc/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class QuoteConfirmationScreen extends StatelessWidget {
  const QuoteConfirmationScreen({super.key, required this.quote});

  final CompletedQuote quote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(quote: quote),
              const SizedBox(height: 28),
              _MetaBlock(label: 'NUMERO POLIZZA', value: quote.id.substring(0, 8).toUpperCase()),
              _MetaBlock(label: 'DATA RINNOVO', value: _formatDate(quote.createdAt)),
              _MetaBlock(
                label: 'PREMIO MENSILE',
                value: '€${(quote.totalPrice / 12).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 28),
              const Text(
                'LIMITI DI COPERTURA',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ...quote.coverages.take(3).map(
                (coverage) => _CoverageLimitCard(
                  title: coverage.title,
                  description: coverage.description,
                  price: coverage.annualPrice,
                ),
              ),
              const SizedBox(height: 20),
              _ClaimsCallout(
                onTap: () => context.go('/home'),
              ),
              const SizedBox(height: 28),
              const Text(
                'DOCUMENTI',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const _DocumentsCard(),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Hai domande sulla tua copertura?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Contatta un consulente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.quote});

  final CompletedQuote quote;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.directions_car_rounded),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            quote.vehicleLabel,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'ATTIVA',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.notifications, size: 18),
        const SizedBox(width: 12),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.accentSoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.person, size: 16),
        ),
      ],
    );
  }
}

class _MetaBlock extends StatelessWidget {
  const _MetaBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageLimitCard extends StatelessWidget {
  const _CoverageLimitCard({
    required this.title,
    required this.description,
    required this.price,
  });

  final String title;
  final String description;
  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, size: 22),
              const Spacer(),
              Text(
                '€${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimsCallout extends StatelessWidget {
  const _ClaimsCallout({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.action,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Devi segnalare un sinistro?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Il nostro assistente sinistri AI è disponibile 24/7 per aiutarti ad aprire subito la pratica.',
            style: TextStyle(
              color: Color(0xFFD6D2CA),
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.textPrimary,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Apri sinistro'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentsCard extends StatelessWidget {
  const _DocumentsCard();

  @override
  Widget build(BuildContext context) {
    const docs = [
      'Policy_Agreement_2024.pdf',
      'Proof_of_Insurance_ID.pdf',
      'Terms_and_Conditions.pdf',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: List.generate(docs.length, (index) {
          final doc = docs[index];
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: index == docs.length - 1
                  ? null
                  : const Border(
                      bottom: BorderSide(color: AppTheme.border),
                    ),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 20, color: AppTheme.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    doc,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.download_rounded, size: 18),
              ],
            ),
          );
        }),
      ),
    );
  }
}
