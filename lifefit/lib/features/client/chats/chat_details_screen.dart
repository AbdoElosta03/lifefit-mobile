import 'package:flutter/material.dart';


class ChatDetailsScreen extends StatelessWidget {
  final String expertName;
  const ChatDetailsScreen({super.key, required this.expertName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(expertName, style: const TextStyle(color: Colors.black, fontSize: 18)),
            const SizedBox(width: 10),
            const CircleAvatar(backgroundColor: Color(0xFFEEEEEE), child: Icon(Icons.person, color: Colors.grey)),
            const SizedBox(width: 15),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // منطقة الرسائل
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMessageBubble("مرحباً بك! كيف يمكنني مساعدتك اليوم؟", false),
                _buildMessageBubble("أهلاً كوتش، أحتاج لتعديل في جدول التمارين", true),
                _buildMessageBubble("بالتأكيد، ما هي التغييرات التي تقترحها؟", false),
              ],
            ),
          ),
          
          // منطقة إدخال النص (Input Field)
          _buildChatInput(),
        ],
      ),
    );
  }

  // ويدجت فقاعة الرسالة
  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00D9D9) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isMe ? Radius.zero : const Radius.circular(15),
            bottomRight: isMe ? const Radius.circular(15) : Radius.zero,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  // منطقة الكتابة في الأسفل
  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          // زر الإرسال
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF00D9D9)),
            onPressed: () {},
          ),
          // حقل النص
          Expanded(
            child: TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                fillColor: const Color(0xFFF5F5F5),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}