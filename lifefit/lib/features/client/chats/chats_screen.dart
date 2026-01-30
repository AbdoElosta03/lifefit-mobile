import 'package:flutter/material.dart';
import 'chat_details_screen.dart'; 

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('المحادثات', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView.separated(
        itemCount: 3, // عدد الخبراء المشترك معهم
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              // الانتقال لشاشة الدردشة
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatDetailsScreen(expertName: "أحمد علي")),
              );
            },
            leading: const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFEEEEEE),
              child: Icon(Icons.person, color: Colors.grey, size: 35),
            ),
            title: const Text(
              'أحمد علي',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.right,
            ),
            subtitle: const Text(
              'آخر رسالة: كيف حال التمرين اليوم؟',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.right,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('10:30 ص', style: TextStyle(color: Colors.grey, fontSize: 11)),
                const SizedBox(height: 5),
                // إشعار بالرسائل الجديدة
                if (index == 0)
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: Color(0xFF00D9D9),
                    child: Text('2', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}