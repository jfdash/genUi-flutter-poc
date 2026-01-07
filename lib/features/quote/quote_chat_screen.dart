// lib/features/quote/screens/quote_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/core/service/ai_service.dart';
import 'package:gen_ui_poc/features/quote/cubit/quote_cubit.dart';
import 'package:gen_ui_poc/features/quote/cubit/quote_state.dart';
import 'package:gen_ui_poc/features/quote/services/coverage_calculator.dart';
import 'package:gen_ui_poc/features/quote/widgets/message_bubble_widget.dart';
import 'package:genui/genui.dart'; // Importante per GenUiSurface

class QuoteChatScreen extends StatelessWidget {
  const QuoteChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuoteCubit(
        calculator: context.read<CoverageCalculator>(),
        aiService: context.read<AIService>(),
      ),
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
      _sendInitialMessage();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendInitialMessage() {
    final aiService = context.read<AIService>();
    if (aiService.messages.isEmpty) {
      aiService.sendMessage('Voglio un preventivo auto');
    }
  }

  void _scrollToBottom() {
    // Usiamo un piccolo delay per permettere alla UI di renderizzare i nuovi widget
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
    final aiService = context.read<AIService>();
    // BLOCCO ANTI-QUOTA: Se sta caricando, non fare nulla
    if (aiService.isLoading) return;

    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    aiService.sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  void _generateQuote() {
    final cubit = context.read<QuoteCubit>();
    cubit.generateCoverageSuggestions(useAI: true);
  }

  @override
  Widget build(BuildContext context) {
    final aiService = context.watch<AIService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Assicurazione AI', style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // Progress bar guidata dal Cubit
          BlocBuilder<QuoteCubit, QuoteState>(
            builder: (context, state) {
              return LinearProgressIndicator(
                value: state.completionPercentage,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(Color(0xFF4F46E5)),
              );
            },
          ),

          // Area Messaggi
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Render dei messaggi testuali
                ...aiService.messages.map(
                  (msg) => MessageBubble(
                    message: msg['content'] as String,
                    isUser: msg['role'] == 'user',
                    timestamp: msg['timestamp'] as DateTime,
                  ),
                ),

                // ✅ GENUI SURFACE: Questo sostituisce la tua vecchia lista di widget.
                // Gestisce automaticamente la visualizzazione dei widget inviati da Gemini.
                if (aiService.isInitialized && aiService.conversation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: GenUiSurface(
                      host: aiService.conversation!.host,
                      surfaceId: 'preventivo_auto', // Deve corrispondere al log!
                      defaultBuilder: (context) => const SizedBox.shrink(),
                    ),
                  ),

                // Messaggio di Errore (es. Quota Exceeded)
                if (aiService.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      aiService.error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Bottone Genera Preventivo
                BlocBuilder<QuoteCubit, QuoteState>(
                  builder: (context, state) {
                    if (!state.isReadyForQuote) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : _generateQuote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          state.isLoading ? 'Calcolo in corso...' : 'Visualizza Preventivo',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Input Bar
          _buildInputBar(aiService),
        ],
      ),
    );
  }

  Widget _buildInputBar(AIService aiService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !aiService.isLoading,
                decoration: InputDecoration(
                  hintText: aiService.isLoading ? 'L\'AI sta scrivendo...' : 'Scrivi qui...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onSubmitted: (_) => aiService.isLoading ? null : _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: aiService.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: Color(0xFF4F46E5)),
              onPressed: aiService.isLoading ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
