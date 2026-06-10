import '../../../../core/ui/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../core/models/chat/chat_message_model.dart';

/// A UI component for displaying individual messages in a chat.
/// Styles the message based on whether it was sent by the current user or received.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timeLabel,
  });

  final ChatMessageModel message;
  final bool isMe;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          // Gradient for user messages, solid light surface for others
          gradient: isMe ? AppColors.primaryGradient : null,
          color: isMe ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 4 : 18),
            bottomRight: Radius.circular(isMe ? 18 : 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // ── Message Text ──────────────────────────────────────────
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            
            // ── Metadata: Time & Read Status ─────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMe) ...[
                  // Tick icons for message delivery status
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 13,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  timeLabel,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
