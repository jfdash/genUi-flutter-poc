import 'package:flutter/material.dart';

class ChoiceChipsWidget extends StatefulWidget {
  final String id;
  final String label;
  final List<String> options;
  final String? value;
  final Function(String) onChanged;

  const ChoiceChipsWidget({
    super.key,
    required this.id,
    required this.label,
    required this.options,
    this.value,
    required this.onChanged,
  });

  @override
  State<ChoiceChipsWidget> createState() => _ChoiceChipsWidgetState();
}

class _ChoiceChipsWidgetState extends State<ChoiceChipsWidget> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options.map((option) {
              final isSelected = _selected == option;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selected = option);
                    widget.onChanged(option);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$option selezionato ✓'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  }
                },
                selectedColor: const Color(0xFF4F46E5).withOpacity(0.2),
                backgroundColor: const Color(0xFFF3F4F6),
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF6B7280),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
                    width: 2,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}