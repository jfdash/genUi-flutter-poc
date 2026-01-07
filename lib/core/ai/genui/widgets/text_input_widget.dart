import 'package:flutter/material.dart';

class TextInputWidget extends StatefulWidget {
  final String id;
  final String label;
  final String? hint;
  final String? value;
  final String? icon;
  final bool required;
  final String? validationPattern;
  final Function(String) onChanged;

  const TextInputWidget({
    super.key,
    required this.id,
    required this.label,
    this.hint,
    this.value,
    this.icon,
    this.required = false,
    this.validationPattern,
    required this.onChanged,
  });

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon(String? iconName) {
    if (iconName == null) return Icons.edit_rounded;
    switch (iconName) {
      case 'car':
        return Icons.directions_car_rounded;
      case 'pin':
        return Icons.pin_drop_rounded;
      case 'person':
        return Icons.person_rounded;
      case 'city':
        return Icons.location_city_rounded;
      case 'calendar':
        return Icons.calendar_today_rounded;
      default:
        return Icons.edit_rounded;
    }
  }

  void _confirm() {
    final value = _controller.text.trim();

    // Validazione
    if (widget.required && value.isEmpty) {
      setState(() => _errorText = '${widget.label} è obbligatorio');
      return;
    }

    if (widget.validationPattern != null && value.isNotEmpty) {
      if (!RegExp(widget.validationPattern!).hasMatch(value)) {
        setState(() => _errorText = 'Formato non valido');
        return;
      }
    }

    setState(() => _errorText = null);
    widget.onChanged(value);

    // Feedback visivo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.label} salvato ✓'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                errorText: _errorText,
                prefixIcon: Icon(_getIcon(widget.icon), size: 20),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) => _confirm(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: const Color(0xFF4F46E5),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _confirm,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}