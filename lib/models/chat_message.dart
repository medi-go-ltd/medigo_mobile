class ChatMessage {
  final String text;
  final bool isFromDoctor;
  final DateTime? sentAt;

  const ChatMessage({
    required this.text,
    required this.isFromDoctor,
    this.sentAt,
  });
}
