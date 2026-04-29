import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/progress/progress_photo.dart';
import '../../../core/models/progress/progress_photos_grouped.dart';
import 'add_progress_photo_sheet.dart';
import 'progress_photos_provider.dart';

class ProgressPhotosScreen extends ConsumerWidget {
  const ProgressPhotosScreen({super.key});

  static const _primary = Color(0xFF00D9D9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(progressPhotosProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'صور التقدم',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddProgressPhotoSheet(context),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('إضافة صورة', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 12),
                Text(e.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.read(progressPhotosProvider.notifier).refresh(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (days) {
          if (days.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 56, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد صور تقدم بعد.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () => showAddProgressPhotoSheet(context),
                      icon: const Icon(Icons.add_a_photo_outlined, color: _primary),
                      label: const Text('إضافة أول صورة', style: TextStyle(fontWeight: FontWeight.w700, color: _primary)),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: _primary,
            onRefresh: () => ref.read(progressPhotosProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: days.length,
              itemBuilder: (context, i) {
                return _DaySection(
                  day: days[i],
                  onDelete: (photo) => _confirmDelete(context, ref, photo),
                );
              },
            ),
          );
        },
      ),
    );
  }

  static Future<void> _confirmDelete(BuildContext context, WidgetRef ref, ProgressPhoto photo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الصورة؟'),
        content: const Text('لن يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('حذف', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(progressPhotosProvider.notifier).deletePhoto(photo.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حذف الصورة'), backgroundColor: _primary),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}

class _DaySection extends StatelessWidget {
  final ProgressPhotosDay day;
  final void Function(ProgressPhoto photo) onDelete;

  const _DaySection({required this.day, required this.onDelete});

  static const _dark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final header = day.sortDate != null
        ? DateFormat.yMMMMEEEEd('ar').format(day.sortDate!)
        : day.dateKey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 4),
            child: Text(
              header,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _dark,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: day.photos.length,
            itemBuilder: (context, j) {
              final p = day.photos[j];
              return _PhotoTile(photo: p, onDelete: () => onDelete(p));
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final ProgressPhoto photo;
  final VoidCallback onDelete;

  const _PhotoTile({required this.photo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final url = photo.photoUrl;
    final typeLabel = _typeAr(photo.photoType);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url.isNotEmpty)
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
              ),
            )
          else
            Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported_outlined, size: 40),
            ),
          Positioned(
            top: 6,
            left: 6,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: onDelete,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.black.withValues(alpha: 0.55),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    typeLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  if (photo.notes != null && photo.notes!.isNotEmpty)
                    Text(
                      photo.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                      textAlign: TextAlign.right,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _typeAr(String code) {
    switch (code) {
      case 'front':
        return 'أمامي';
      case 'back':
        return 'خلفي';
      case 'side':
        return 'جانبي';
      case 'inbody':
        return 'InBody';
      case 'other':
        return 'أخرى';
      default:
        return code;
    }
  }
}
