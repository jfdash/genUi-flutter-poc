// lib/features/quote/screens/quote_result_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/features/quote/cubit/quote_cubit.dart';
import 'package:gen_ui_poc/features/quote/cubit/quote_state.dart';
import 'package:gen_ui_poc/features/quote/widgets/coverage_card_widget.dart';
import 'package:gen_ui_poc/features/quote/widgets/quote_summary_card_widget.dart';

class QuoteResultScreen extends StatelessWidget {
  const QuoteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Il Tuo Preventivo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF4F46E5)),
            onPressed: () {
              // TODO: Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Condivisione non implementata')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<QuoteCubit, QuoteState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Calcolo preventivo in corso...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Torna Indietro'),
                  ),
                ],
              ),
            );
          }

          if (state.coverageSuggestions.isEmpty) {
            return const Center(
              child: Text('Nessun suggerimento disponibile'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quote Summary
              QuoteSummaryCard(
                vehicleData: state.vehicleData,
                driverData: state.driverData,
                suggestions: state.coverageSuggestions,
              ),

              const SizedBox(height: 24),

              // Loading Explanations Indicator
              if (state.isLoadingExplanations)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Generazione spiegazioni AI...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (state.isLoadingExplanations) const SizedBox(height: 16),

              // Section Title
              const Text(
                'Coperture Consigliate',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Basate sul tuo profilo e calcolate con logica deterministico',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),

              // Coverage Cards
              ...state.coverageSuggestions.map((suggestion) {
                return CoverageCard(
                  suggestion: suggestion,
                  isLoadingExplanation: state.isLoadingExplanations,
                );
              }).toList(),

              const SizedBox(height: 24),

              // CTA Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Proceed to purchase
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Acquisto non implementato (POC)'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Procedi con Acquisto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Back Button
              OutlinedButton(
                onPressed: () => Navigator.popUntil(
                  context,
                  (route) => route.isFirst,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF4F46E5)),
                ),
                child: const Text(
                  'Nuovo Preventivo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}