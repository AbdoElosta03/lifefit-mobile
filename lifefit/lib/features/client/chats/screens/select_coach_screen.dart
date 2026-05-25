import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/subscription/expert_model.dart';
import '../../../../core/services/chat_service.dart';
import '../providers/chat_providers.dart';
import '../../subscription/subscription_provider.dart';
import 'chat_details_screen.dart';

/// Displays the coaches/nutritionists that the client is subscribed to.
/// Reuses [expertsProvider] (GET /api/client/available-experts) and filters
/// to [ExpertModel.isSubscribed] == true so no new endpoint is needed.
///
/// On selection, calls POST /api/client/chats/start via [ChatService], then
/// initialises the Firestore document and navigates to [ChatDetailsScreen].
class SelectCoachScreen extends ConsumerStatefulWidget {
  const SelectCoachScreen({super.key});

  @override
  ConsumerState<SelectCoachScreen> createState() => _SelectCoachScreenState();
}

class _SelectCoachScreenState extends ConsumerState<SelectCoachScreen> {
  static const _primary = Color(0xFF00D9D9);

  String? _loadingCoachId;

  Future<void> _openChat(ExpertModel expert) async {
    setState(() => _loadingCoachId = expert.id.toString());

    try {
      final chatService = ChatService();
      final response = await chatService.startChat(coachId: expert.id);

      final firestoreService = ref.read(firestoreChatServiceProvider);

      await firestoreService.ensureChatDoc(
        chatId: response.firebaseChatId,
        clientId: response.clientId.toString(),
        clientName: response.clientName,
        clientAvatarUrl: response.clientAvatarUrl,
        coachId: response.coachId.toString(),
        coachName: response.coachName,
        coachAvatarUrl: response.coachAvatarUrl,
        type: response.type,
        status: response.status,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailsScreen(
            chatId: response.firebaseChatId,
            title: response.coachName,
            peerId: response.coachId.toString(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingCoachId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final expertsAsync = ref.watch(expertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: const Text(
          'اختر مدرباً',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: expertsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primary),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(expertsProvider.notifier).refresh(),
        ),
        data: (experts) {
          final subscribed =
              experts.where((e) => e.isSubscribed).toList();

          if (subscribed.isEmpty) {
            return const _EmptyView();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: subscribed.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final expert = subscribed[index];
              final isLoading =
                  _loadingCoachId == expert.id.toString();

              return _CoachTile(
                expert: expert,
                isLoading: isLoading,
                onTap: _loadingCoachId != null ? null : () => _openChat(expert),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────── private widgets ────────────────────────────────

class _CoachTile extends StatelessWidget {
  const _CoachTile({
    required this.expert,
    required this.isLoading,
    required this.onTap,
  });

  final ExpertModel expert;
  final bool isLoading;
  final VoidCallback? onTap;

  static const _primary = Color(0xFF00D9D9);
  static const _dark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final roleLabel =
        expert.role == 'trainer' ? 'مدرب رياضي' : 'أخصائي تغذية';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _Avatar(url: expert.avatarUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleLabel,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _primary),
                )
              else
                const Icon(Icons.chat_bubble_outline_rounded,
                    color: _primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(url!),
        backgroundColor: Colors.grey[200],
      );
    }
    return const CircleAvatar(
      radius: 26,
      backgroundColor: Color(0xFFE0FAFA),
      child: Icon(Icons.person, color: Color(0xFF00D9D9), size: 28),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا يوجد مدربون مشترك معهم',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'اشترك مع مدرب أو أخصائي تغذية لبدء المحادثة.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
