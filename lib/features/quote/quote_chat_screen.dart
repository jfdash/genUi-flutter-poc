// lib/features/quote/screens/quote_chat_screen_event_driven.dart

import 'package:flutter/material.dart';
import 'package:gen_ui_poc/core/event/event_aggregator.dart';
import 'package:gen_ui_poc/core/service/ai_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:genui/genui.dart';

class QuoteChatScreenEventDriven extends StatelessWidget {
  const QuoteChatScreenEventDriven({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AIServiceEventDriven(),
      child: const _QuoteChatView(),
    );
  }
}

class _QuoteChatView extends StatefulWidget {
  const _QuoteChatView();

  @override
  State<_QuoteChatView> createState() => _QuoteChatViewState();
}

class _QuoteChatViewState extends State<_QuoteChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    final aiService = context.read<AIServiceEventDriven>();

    // Callback per navigare alla conferma quando il preventivo è completato
    aiService.onQuoteCompleted = (quote) {
      // Attendi che l'AI mostri il riepilogo, poi naviga
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Reset chat allo stato iniziale
          aiService.reset();
          aiService.addMessage(
            'assistant',
            'Ciao! Sono il tuo assistente AI per preventivi auto.\n\n'
                'Scrivi "preventivo" o "iniziamo" per partire!',
          );
          context.push('/confirmation', extra: quote);
        }
      });
    };

    // Messaggio di benvenuto
    if (aiService.messages.isEmpty) {
      aiService.addMessage(
        'assistant',
        'Ciao! Sono il tuo assistente AI per preventivi auto.\n\n'
            'Scrivi "preventivo" o "iniziamo" per partire!',
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final aiService = context.read<AIServiceEventDriven>();
    if (aiService.isLoading) return;

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    aiService.sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final aiService = context.watch<AIServiceEventDriven>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: Color(0xFF4F46E5), size: 24),
            SizedBox(width: 8),
            Text(
              'Assicurazione AI',
              style: TextStyle(color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // Debug: mostra contatore eventi
          _buildEventCounter(aiService),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () => aiService.reset(),
            tooltip: 'Reset conversazione',
          ),
        ],
      ),
      body: Column(
        children: [
          if (aiService.isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Color(0xFF4F46E5)),
            ),

          // ═══════════════════════════════════════════════════════
          // AREA MESSAGGI + WIDGET
          // ═══════════════════════════════════════════════════════
          Expanded(
            child: ChangeNotifierProvider<EventAggregator>.value(
              value: aiService.eventAggregator,
              child: _buildMessageList(aiService),
            ),
          ),

          // Error display
          if (aiService.error != null) _buildErrorBanner(aiService.error!),

          // Input bar
          _buildInputBar(aiService),
        ],
      ),
    );
  }

  Widget _buildEventCounter(AIServiceEventDriven aiService) {
    return Consumer<AIServiceEventDriven>(
      builder: (context, service, _) {
        final count = service.eventAggregator.collectedData.length;
        if (count == 0) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.data_object, size: 16, color: Color(0xFF4F46E5)),
              const SizedBox(width: 4),
              Text(
                '$count campi',
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList(AIServiceEventDriven aiService) {
    // Trova l'ultimo widget message per mostrare solo quello
    final lastWidgetMessage = aiService.messages
        .where((m) => m['role'] == 'assistant_widget')
        .lastOrNull;
    final lastWidgetSurfaceId = lastWidgetMessage?['surfaceId'] as String?;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: aiService.messages.length,
      itemBuilder: (context, index) {
        final msg = aiService.messages[index];
        final role = msg['role'] as String;

        // Messaggio utente
        if (role == 'user') {
          return _UserMessageBubble(
            message: msg['content'] as String,
            timestamp: msg['timestamp'] as DateTime,
          );
        }

        // Messaggio assistente (testo)
        if (role == 'assistant') {
          return _AssistantMessageBubble(
            message: msg['content'] as String,
            timestamp: msg['timestamp'] as DateTime,
          );
        }

        // Widget GenUI - mostra SOLO l'ultimo
        if (role == 'assistant_widget') {
          final surfaceId = msg['surfaceId'] as String?;

          // Salta se non è l'ultimo widget
          if (surfaceId != lastWidgetSurfaceId) {
            return const SizedBox.shrink();
          }

          if (surfaceId == null || aiService.conversation == null) {
            return const SizedBox.shrink();
          }

          return _WidgetSurface(host: aiService.conversation!.host, surfaceId: surfaceId);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red.shade50,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(error, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(AIServiceEventDriven aiService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !aiService.isLoading,
                decoration: InputDecoration(
                  hintText: aiService.isLoading
                      ? 'L\'AI sta elaborando...'
                      : 'Scrivi un messaggio...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            _buildSendButton(aiService),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(AIServiceEventDriven aiService) {
    if (aiService.isLoading) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
        child: const Center(
          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    return GestureDetector(
      onTap: _sendMessage,
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(color: Color(0xFF4F46E5), shape: BoxShape.circle),
        child: const Icon(Icons.send, color: Colors.white, size: 22),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MESSAGE BUBBLES
// ═══════════════════════════════════════════════════════════════════

class _UserMessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;

  const _UserMessageBubble({required this.message, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5),
          borderRadius: BorderRadius.circular(20).copyWith(bottomRight: const Radius.circular(4)),
        ),
        child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ),
    );
  }
}

class _AssistantMessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;

  const _AssistantMessageBubble({required this.message, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(4)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(message, style: const TextStyle(color: Colors.black87, fontSize: 15)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// WIDGET SURFACE - Container per widget GenUI
// ═══════════════════════════════════════════════════════════════════

class _WidgetSurface extends StatelessWidget {
  final GenUiHost host;
  final String surfaceId;

  const _WidgetSurface({required this.host, required this.surfaceId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GenUiSurface(
        host: host,
        surfaceId: surfaceId,
        defaultBuilder: (context) => const Center(
          child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
