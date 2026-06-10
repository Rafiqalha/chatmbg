/// Data models for chat feature.
library;

class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  String content;
  final List<Citation> citations;
  final DateTime timestamp;
  MessageStatus status;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.citations = const [],
    DateTime? timestamp,
    this.status = MessageStatus.done,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}

class Citation {
  final String regulation;
  final String article;
  final String excerpt;

  const Citation({
    required this.regulation,
    required this.article,
    required this.excerpt,
  });

  factory Citation.fromJson(Map<String, dynamic> json) => Citation(
        regulation: json['regulation'] as String? ?? '',
        article: json['article'] as String? ?? '',
        excerpt: json['excerpt'] as String? ?? '',
      );
}

enum MessageStatus { pending, streaming, done, error }
