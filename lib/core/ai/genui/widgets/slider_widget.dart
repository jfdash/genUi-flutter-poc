import 'package:flutter/material.dart';

class SliderWidget extends StatefulWidget {
  final String id;
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final String? unit;
  final Function(double) onChanged;

  const SliderWidget({
    super.key,
    required this.id,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    this.unit,
    required this.onChanged,
  });

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
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
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF4F46E5),
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    thumbColor: const Color(0xFF4F46E5),
                    overlayColor: const Color(0xFF4F46E5).withOpacity(0.2),
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    value: _currentValue,
                    min: widget.min,
                    max: widget.max,
                    divisions: ((widget.max - widget.min) / widget.step).round(),
                    label: '${_currentValue.toStringAsFixed(0)}${widget.unit ?? ''}',
                    onChanged: (value) {
                      setState(() => _currentValue = value);
                    },
                    onChangeEnd: (value) {
                      widget.onChanged(value);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.label}: ${value.toStringAsFixed(0)}${widget.unit ?? ''} ✓'),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_currentValue.toStringAsFixed(0)}${widget.unit ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4F46E5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}