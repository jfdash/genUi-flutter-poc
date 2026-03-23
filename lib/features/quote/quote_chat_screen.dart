import 'package:flutter/material.dart';
import 'package:gen_ui_poc/core/model/completed_quote_model.dart';
import 'package:gen_ui_poc/core/service/ai_service.dart';
import 'package:gen_ui_poc/core/theme/app_theme.dart';
import 'package:gen_ui_poc/features/quote/widgets/chat_quotes_widgets.dart';
import 'package:genui/genui.dart';
import 'package:provider/provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeChat());
  }

  void _initializeChat() {
    final aiService = context.read<AIServiceEventDriven>();
    aiService.onQuoteCompleted = (quote) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          _scrollToBottom();
        }
      });
    };

    if (aiService.messages.isEmpty) {
      aiService.addMessage('assistant', aiService.welcomeMessage);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final aiService = context.read<AIServiceEventDriven>();
    if (aiService.isLoading) {
      return;
    }

    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    aiService.sendMessage(message);
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 250), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiService = context.watch<AIServiceEventDriven>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _ChatTopBar(aiService: aiService),
            Expanded(child: _buildContent(aiService)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AIServiceEventDriven aiService) {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 146),
          itemCount: aiService.messages.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _ChatHero();
            }
            final message = aiService.messages[index - 1];
            return _buildMessage(aiService, message);
          },
        ),
        if (aiService.error != null)
          Positioned(
            left: 18,
            right: 18,
            bottom: 104,
            child: _ErrorBanner(error: aiService.error!),
          ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _InputBar(
            controller: _messageController,
            isLoading: aiService.isLoading,
            onSend: _sendMessage,
          ),
        ),
      ],
    );
  }

  Widget _buildMessage(
    AIServiceEventDriven aiService,
    Map<String, dynamic> message,
  ) {
    final role = message['role'] as String;
    final lastWidgetMessage = aiService.messages
        .where((m) => m['role'] == 'assistant_widget')
        .lastOrNull;
    final lastWidgetSurfaceId = lastWidgetMessage?['surfaceId'] as String?;

    if (role == 'user') {
      return _UserMessageBlock(message: message['content'] as String);
    }

    if (role == 'assistant') {
      return _AssistantMessageBlock(message: message['content'] as String);
    }

    if (role == 'assistant_quotes_list') {
      return ChatQuotesList(quotes: (message['quotes'] as List).cast<CompletedQuote>());
    }

    if (role == 'assistant_quotes_empty') {
      return const ChatEmptyQuotesState();
    }

    if (role == 'assistant_widget') {
      final surfaceId = message['surfaceId'] as String?;
      if (surfaceId == null ||
          aiService.host == null ||
          surfaceId != lastWidgetSurfaceId) {
        return const SizedBox.shrink();
      }
      return _WidgetSurface(host: aiService.host!, surfaceId: surfaceId);
    }

    return const SizedBox.shrink();
  }
}

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar({required this.aiService});

  final AIServiceEventDriven aiService;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(Icons.shield_outlined, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Assistente AI',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          if (aiService.activeFieldCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${aiService.activeFieldCount} FIELDS',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          IconButton(
            onPressed: aiService.reset,
            icon: const Icon(Icons.notifications, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ChatHero extends StatelessWidget {
  const _ChatHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 122, color: AppTheme.textPrimary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATO ASSISTENTE: ATTIVO',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Come posso proteggere i tuoi beni oggi?',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          const Text(
            'RISPOSTA CURATOR AI',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.3,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMessageBlock extends StatelessWidget {
  const _UserMessageBlock({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18, right: 44, top: 8),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                height: 1.55,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                '10:42 AM',
                style: TextStyle(fontSize: 12, color: AppTheme.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantMessageBlock extends StatelessWidget {
  const _AssistantMessageBlock({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18, right: 38),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.action,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.55,
        ),
      ),
    );
  }
}

class _WidgetSurface extends StatelessWidget {
  const _WidgetSurface({required this.host, required this.surfaceId});

  final GenUiHost host;
  final String surfaceId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
      ),
      child: GenUiSurface(
        host: host,
        surfaceId: surfaceId,
        defaultBuilder: (context) => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        child: Row(
          children: [
            const Icon(Icons.attach_file_rounded, color: AppTheme.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  hintText: 'Chiedi all’assistente AI qualsiasi cosa sulla tua copertura...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isLoading ? null : onSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.action,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0CECE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF9F3131), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Color(0xFF9F3131), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
