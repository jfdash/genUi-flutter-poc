import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  final String message;
  final String type; 
  final String? title;
  final IconData? icon;

  const InfoCardWidget({
    super.key,
    required this.message,
    this.type = 'info',
    this.title,
    this.icon,
  });

  Color _getColor() {
    switch (type) {
      case 'success':
        return const Color(0xFF059669);
      case 'warning':
        return const Color(0xFFD97706);
      case 'error':
        return const Color(0xFFDC2626);
      case 'info':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getIcon() {
    if (icon != null) return icon!;
    switch (type) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.warning_rounded;
      case 'error':
        return Icons.error_rounded;
      case 'info':
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final iconData = _getIcon();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(iconData, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                    height: 1.4,
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