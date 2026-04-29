import 'progress_photo.dart';

/// One calendar day bucket from Laravel `groupBy('date')` JSON: `{ "2026-04-12": [ {...}, ... ] }`.
class ProgressPhotosDay {
  final String dateKey;
  final DateTime? sortDate;
  final List<ProgressPhoto> photos;

  const ProgressPhotosDay({
    required this.dateKey,
    required this.sortDate,
    required this.photos,
  });

  /// Parses `response.data['data']` when it is a Map of date string -> list of photo objects.
  static List<ProgressPhotosDay> parseGroupedData(dynamic raw) {
    if (raw == null || raw is! Map) return [];

    final days = <ProgressPhotosDay>[];
    for (final entry in Map<dynamic, dynamic>.from(raw).entries) {
      final key = entry.key.toString();
      final value = entry.value;
      if (value is! List) continue;

      final photos = value
          .whereType<Map>()
          .map((m) => ProgressPhoto.fromJson(Map<String, dynamic>.from(m)))
          .toList();

      final firstPhotoDate = photos.isEmpty ? null : photos.first.date;
      final sortDate = DateTime.tryParse(key) ??
          DateTime.tryParse(key.split(' ').first) ??
          firstPhotoDate;

      days.add(ProgressPhotosDay(dateKey: key, sortDate: sortDate, photos: photos));
    }

    days.sort((a, b) {
      final da = a.sortDate;
      final db = b.sortDate;
      if (da == null && db == null) return b.dateKey.compareTo(a.dateKey);
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    return days;
  }
}
