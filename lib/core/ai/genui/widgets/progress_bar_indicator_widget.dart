import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  final String? label;
  final double value;
  final bool showPercentage;

  const ProgressBarWidget({
    super.key,
    this.label,
    required this.value,
    this.showPercentage = true,
  });

  Color _getColor() {
    if (value < 0.33) return const Color(0xFFDC2626);
    if (value < 0.66) return const Color(0xFFD97706);
    return const Color(0xFF059669);
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final percentage = (value * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                if (showPercentage)
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}