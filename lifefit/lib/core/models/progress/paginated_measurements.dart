import 'body_measurement.dart';

/// Laravel `LengthAwarePaginator` JSON shape.
class PaginatedMeasurements {
  final int currentPage;
  final int lastPage;
  final int total;
  final List<BodyMeasurement> data;

  const PaginatedMeasurements({
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.data,
  });

  factory PaginatedMeasurements.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => BodyMeasurement.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <BodyMeasurement>[];

    return PaginatedMeasurements(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      total: (json['total'] as num?)?.toInt() ?? list.length,
      data: list,
    );
  }
}
