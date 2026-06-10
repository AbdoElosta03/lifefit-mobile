import '../../../../core/ui/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/chat/chat_model.dart';

/// A custom list tile for displaying a chat summary in a list.
/// Used in the [ChatListScreen] to show recent conversations.
class ChatListTile extends StatelessWidget {
  const ChatListTile({
    super.key,
    required this.chat,
    required this.title,
    required this.onTap,
    required this.accentColor,
  });

  final ChatModel chat;
  final String title;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    // Truncate message text for the subtitle preview
    final subtitle = chat.lastMessage?.trim();
    final time = chat.lastMessageAt;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5, // Subtle shadow for a clean look
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // ── Avatar Section ──────────────────────────────────────────
              // Uses a placeholder icon with an accent background
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              
              // ── Text Content ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // RTL alignment
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Timestamp for the last message
                        if (time != null)
                          Text(
                            DateFormat.Hm().format(time),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                          
                        // Participant Name/Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Message Preview
                    Text(
                      subtitle?.isNotEmpty == true
                          ? subtitle!
                          : 'ابدأ المحادثة الآن...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
