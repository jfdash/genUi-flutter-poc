import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputWidget extends StatefulWidget {
  final String id;
  final String label;
  final String? hint;
  final int? value;
  final int? min;
  final int? max;
  final Function(int) onChanged;

  const NumberInputWidget({
    super.key,
    required this.id,
    required this.label,
    this.hint,
    this.value,
    this.min,
    this.max,
    required this.onChanged,
  });

  @override
  State<NumberInputWidget> createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() => _errorText = '${widget.label} è obbligatorio');
      return;
    }

    final number = int.tryParse(text);
    if (number == null) {
      setState(() => _errorText = 'Inserisci un numero valido');
      return;
    }

    if (widget.min != null && number < widget.min!) {
      setState(() => _errorText = 'Minimo: ${widget.min}');
      return;
    }

    if (widget.max != null && number > widget.max!) {
      setState(() => _errorText = 'Massimo: ${widget.max}');
      return;
    }

    setState(() => _errorText = null);
    widget.onChanged(number);

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
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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