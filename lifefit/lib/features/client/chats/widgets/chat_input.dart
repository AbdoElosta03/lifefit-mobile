import '../../../../core/ui/app_colors.dart';
import 'package:flutter/material.dart';

/// The input component at the bottom of the chat screen.
/// Handles text entry, typing indicators, and message submission.
class ChatInput extends StatefulWidget {
  const ChatInput({
    super.key,
    required this.onSend,
    required this.onTypingChanged,
    required this.isSending,
  });

  final ValueChanged<String> onSend;
  final ValueChanged<bool> onTypingChanged;
  final bool isSending;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Sends the message if not empty and not currently uploading/sending.
  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) return;

    widget.onSend(text);
    _controller.clear();
    widget.onTypingChanged(false); // Stop typing status after sending
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // ── Send Button ───────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: IconButton(
                  onPressed: widget.isSending ? null : _handleSend,
                  icon: widget.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              
              // ── Text Input Field ──────────────────────────────────────
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textAlign: TextAlign.right, // RTL support
                  onChanged: (value) =>
                      widget.onTypingChanged(value.trim().isNotEmpty),
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك هنا...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
