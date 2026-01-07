// lib/features/quote/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          )
                        : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(
                            color: const Color(0xFFE5E7EB),
                          ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser ? Colors.white : const Color(0xFF111827),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              )
            : const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'Ora';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m fa';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h fa';
    } else {
      return DateFormat('dd/MM HH:mm').format(time);
    }
  }
}