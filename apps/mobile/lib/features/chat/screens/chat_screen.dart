import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/mbg_theme.dart';
import '../../../shared/api/api_client.dart';
import '../../../shared/constants.dart';
import '../../../shared/models/chat_message.dart';
import '../../../shared/widgets/widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <ChatMessage>[];
  bool _isLoading = false;
  StreamSubscription? _streamSub;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _streamSub?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? text]) async {
    final content = (text ?? _controller.text).trim();
    if (content.isEmpty || _isLoading) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: content,
    );
    final assistantMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_a',
      role: 'assistant',
      content: '',
      status: MessageStatus.streaming,
    );

    setState(() {
      _messages.addAll([userMsg, assistantMsg]);
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final api = ref.read(apiClientProvider);
      final stream = api.chatStream(content);
      final citations = <Citation>[];

      await for (final chunk in stream) {
        if (chunk.containsKey('delta')) {
          assistantMsg.content += chunk['delta'] as String;
        }
        if (chunk.containsKey('citations')) {
          final raw = chunk['citations'] as List<dynamic>?;
          if (raw != null) {
            citations.addAll(
              raw.map((e) => Citation.fromJson(e as Map<String, dynamic>)),
            );
          }
        }
        setState(() {});
        _scrollToBottom();
      }

      setState(() {
        assistantMsg.status = MessageStatus.done;
        if (citations.isNotEmpty) {
          final idx = _messages.indexOf(assistantMsg);
          _messages[idx] = ChatMessage(
            id: assistantMsg.id,
            role: 'assistant',
            content: assistantMsg.content,
            citations: citations,
            timestamp: assistantMsg.timestamp,
            status: MessageStatus.done,
          );
        }
      });
    } catch (e) {
      debugPrint('Chat error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${e.toString().split('\n').first}'),
          ),
        );
      }
      setState(() {
        assistantMsg.content = '';
        assistantMsg.status = MessageStatus.error;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _EmptyState(onPromptTap: _sendMessage)
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _messages.length + (_isLoading && _messages.last.content.isEmpty ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _messages.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: TypingIndicator(),
                      );
                    }
                    return _MessageBubble(
                      message: _messages[i],
                      isLast: i == _messages.length - 1,
                    );
                  },
                ),
        ),
        _buildInputBar(isDark),
      ],
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? MBGColors.neutral200.withValues(alpha: 0.08)
                : MBGColors.outlineVariant,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2B2926) : const Color(0xFFF0EFEA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Tanyakan tentang MBG...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintStyle: TextStyle(
                    color: MBGColors.neutral500.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _controller.text.trim().isNotEmpty && !_isLoading
                  ? MBGColors.primary
                  : (isDark ? MBGColors.neutral700 : MBGColors.neutral300),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              icon: Icon(
                _isLoading ? Icons.stop_rounded : Icons.send_rounded,
                size: 20,
                color: _controller.text.trim().isNotEmpty && !_isLoading
                    ? Colors.white
                    : (isDark ? MBGColors.neutral500 : MBGColors.neutral400),
              ),
              onPressed: () => _sendMessage(),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onPromptTap;
  const _EmptyState({required this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MBGColors.primary, MBGColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: MBGColors.primary.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
              Text(
                  'Selamat datang di MBGBrain',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
            const SizedBox(height: 8),
            Text(
              'Asisten AI untuk program Makan Bergizi Gratis.\nTanyakan regulasi, validasi menu, atau cari supplier.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: MBGColors.neutral500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ...AppConstants.quickPrompts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onPromptTap(p.text),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1D1B)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? MBGColors.neutral200.withValues(alpha: 0.1)
                              : MBGColors.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            p.icon,
                            size: 22,
                            color: MBGColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.category,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: MBGColors.primary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : MBGColors.neutral800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: MBGColors.neutral400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Message Bubble ──────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLast;
  const _MessageBubble({required this.message, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: const BoxDecoration(
                color: MBGColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? MBGColors.primary
                        : (isDark
                            ? const Color(0xFF1E1D1B)
                            : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 18),
                    ),
                    border: message.isUser
                        ? null
                        : Border.all(
                            color: isDark
                                ? MBGColors.neutral200.withValues(alpha: 0.1)
                                : MBGColors.outlineVariant,
                          ),
                  ),
                  child: message.status == MessageStatus.error
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 16, color: MBGColors.error),
                            const SizedBox(width: 6),
                            Text(
                              'Terjadi kesalahan. Coba lagi.',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: MBGColors.error),
                            ),
                          ],
                        )
                      : Text(
                          message.content.isEmpty &&
                                  message.status == MessageStatus.streaming
                              ? '...'
                              : message.content,
                          style: TextStyle(
                            fontSize: 14,
                            color: message.isUser
                                ? Colors.white
                                : (isDark
                                    ? Colors.white
                                    : MBGColors.onSurface),
                            height: 1.5,
                          ),
                        ),
                ),
                if (!message.isUser &&
                    message.citations.isNotEmpty &&
                    message.status == MessageStatus.done)
                  _CitationCard(citations: message.citations),
                if (!message.isUser &&
                    message.status == MessageStatus.done)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionBtn(
                          icon: Icons.copy_rounded,
                          tooltip: 'Salin',
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: message.content));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Disalin'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        _ActionBtn(
                          icon: Icons.thumb_up_outlined,
                          tooltip: 'Membantu',
                          onTap: () {},
                        ),
                        _ActionBtn(
                          icon: Icons.thumb_down_outlined,
                          tooltip: 'Tidak membantu',
                          onTap: () {},
                        ),
                      ],
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

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 16),
      tooltip: tooltip,
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      color: MBGColors.neutral500,
      splashRadius: 16,
    );
  }
}

// ─── Citation Card ───────────────────────────────────────────────────────────

class _CitationCard extends StatefulWidget {
  final List<Citation> citations;
  const _CitationCard({required this.citations});

  @override
  State<_CitationCard> createState() => _CitationCardState();
}

class _CitationCardState extends State<_CitationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: isDark
            ? MBGColors.primary.withValues(alpha: 0.08)
            : MBGColors.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? MBGColors.primary.withValues(alpha: 0.15)
              : MBGColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_rounded,
                      size: 14, color: MBGColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.citations.length} sumber regulasi',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: MBGColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: MBGColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            ...widget.citations.map(
              (c) => Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: MBGColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            c.regulation,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            c.article,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: MBGColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '"${c.excerpt}"',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: MBGColors.neutral500,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
