import 'package:flutter/material.dart';

class TextMessageWidget extends StatelessWidget {
  final String message;

  const TextMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(fontSize: 14, height: 1.4)),
    );
  }
}
