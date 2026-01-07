// lib/features/quote/widgets/coverage_card.dart
import 'package:flutter/material.dart';
import 'package:gen_ui_poc/core/model/cover_suggestion_model.dart';

class CoverageCard extends StatefulWidget {
  final CoverageSuggestion suggestion;
  final bool isLoadingExplanation;

  const CoverageCard({
    super.key,
    required this.suggestion,
    this.isLoadingExplanation = false,
  });

  @override
  State<CoverageCard> createState() => _CoverageCardState();
}

class _CoverageCardState extends State<CoverageCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final suggestion = widget.suggestion;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: suggestion.levelColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Level Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: suggestion.levelColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              suggestion.levelEmoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              suggestion.levelLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: suggestion.levelColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Price
                      Text(
                        '€${suggestion.annualPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Text(
                        '/anno',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    suggestion.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Expand indicator
                  Row(
                    children: [
                      Text(
                        _isExpanded ? 'Nascondi dettagli' : 'Mostra dettagli',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF4F46E5),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Reason
                  if (widget.isLoadingExplanation)
                    _buildLoadingSection()
                  else if (suggestion.reason != null) ...[
                    _buildSectionTitle('Perché questo livello?'),
                    const SizedBox(height: 8),
                    Text(
                      suggestion.reason!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Pros
                  if (suggestion.pros != null && suggestion.pros!.isNotEmpty) ...[
                    _buildSectionTitle('Vantaggi'),
                    const SizedBox(height: 8),
                    ...suggestion.pros!.map((pro) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF059669),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pro,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],

                  // Cons
                  if (suggestion.cons != null && suggestion.cons!.isNotEmpty) ...[
                    _buildSectionTitle('Considerazioni'),
                    const SizedBox(height: 8),
                    ...suggestion.cons!.map((con) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                con,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  // Risk Factors (Debug Info)
                  if (suggestion.riskFactors != null) ...[
                    const Divider(height: 32),
                    _buildSectionTitle('Fattori di Rischio Calcolati'),
                    const SizedBox(height: 8),
                    _buildRiskBar(
                      'Rischio Furto',
                      suggestion.riskFactors!.theftRisk,
                    ),
                    const SizedBox(height: 8),
                    _buildRiskBar(
                      'Rischio Incidenti',
                      suggestion.riskFactors!.accidentRisk,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4F46E5).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Generazione spiegazione AI...',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBar(String label, double value) {
    Color color;
    if (value < 0.33) {
      color = const Color(0xFF059669);
    } else if (value < 0.66) {
      color = const Color(0xFFD97706);
    } else {
      color = const Color(0xFFDC2626);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}