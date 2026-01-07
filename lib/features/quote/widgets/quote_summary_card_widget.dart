// lib/features/quote/widgets/quote_summary_card.dart
import 'package:flutter/material.dart';
import 'package:gen_ui_poc/core/model/cover_suggestion_model.dart';
import 'package:gen_ui_poc/core/model/driver_data_model.dart';
import 'package:gen_ui_poc/core/model/vehicle_data_model.dart';

class QuoteSummaryCard extends StatelessWidget {
  final VehicleDataModel vehicleData;
  final DriverDataModel driverData;
  final List<CoverageSuggestion> suggestions;

  const QuoteSummaryCard({
    super.key,
    required this.vehicleData,
    required this.driverData,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = suggestions.fold<double>(
      0,
      (sum, s) => sum + s.annualPrice,
    );

    final essentialPrice = suggestions
        .where((s) => s.level == SuggestionLevel.essential)
        .fold<double>(0, (sum, s) => sum + s.annualPrice);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Il Tuo Preventivo',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Vehicle Info
          _buildInfoRow(
            Icons.directions_car_rounded,
            '${vehicleData.brand} ${vehicleData.model}',
            '${vehicleData.year}',
          ),
          const SizedBox(height: 8),

          // Driver Info
          _buildInfoRow(
            Icons.person_rounded,
            '${driverData.firstName} ${driverData.lastName}',
            '${driverData.age} anni',
          ),
          const SizedBox(height: 8),

          // City
          _buildInfoRow(
            Icons.location_city_rounded,
            driverData.city ?? 'N/D',
            '',
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Totale:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€${totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const Text(
                    '/anno',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Essential Only Price
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Solo essenziali: €${essentialPrice.toStringAsFixed(0)}/anno',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        if (value.isNotEmpty)
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}