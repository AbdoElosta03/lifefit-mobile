import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/progress/body_measurement.dart';

const Color _kPrimary = Color(0xFF00D9D9);
const Color _kDark = Color(0xFF1E293B);

/// Weight vs time (index axis) with optional horizontal target line.
class WeightProgressChart extends StatelessWidget {
  final List<BodyMeasurement> sortedAsc;
  final double? targetWeightKg;

  const WeightProgressChart({
    super.key,
    required this.sortedAsc,
    this.targetWeightKg,
  });

  @override
  Widget build(BuildContext context) {
    final withWeight = sortedAsc
        .where((m) => m.weightKg != null && m.date != null)
        .toList();

    if (withWeight.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'لا توجد نقاط وزن لعرضها في الرسم.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
          ),
        ),
      );
    }

    final ys = withWeight.map((m) => m.weightKg!).toList();
    var minY = ys.reduce(math.min);
    var maxY = ys.reduce(math.max);
    final t = targetWeightKg;
    if (t != null) {
      minY = math.min(minY, t);
      maxY = math.max(maxY, t);
    }
    final span = (maxY - minY).abs();
    final pad = span < 0.01 ? 2.0 : span * 0.12;
    minY -= pad;
    maxY += pad;

    final n = withWeight.length;
    final maxX = n <= 1 ? 1.0 : (n - 1).toDouble();

    final spots = <FlSpot>[
      for (var i = 0; i < n; i++) FlSpot(i.toDouble(), withWeight[i].weightKg!),
    ];

    final dateFmt = DateFormat('d/M', 'ar');

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.grey.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, meta) => Text(
                  v.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: n <= 5 ? 1 : math.max(1, (n / 4).floorToDouble()),
                getTitlesWidget: (v, meta) {
                  final i = v.round().clamp(0, n - 1);
                  final d = withWeight[i].date;
                  if (d == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      dateFmt.format(d),
                      style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              if (t != null)
                HorizontalLine(
                  y: t,
                  color: Colors.deepOrange.withValues(alpha: 0.85),
                  strokeWidth: 1.5,
                  dashArray: const [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.only(right: 4, bottom: 2),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.deepOrange.shade800,
                      fontWeight: FontWeight.w700,
                    ),
                    labelResolver: (_) => 'هدف ${t.toStringAsFixed(1)}',
                  ),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: n > 2,
              color: _kPrimary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: _kPrimary.withValues(alpha: 0.12),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) {
                return touched.map((s) {
                  final idx = s.x.round().clamp(0, n - 1);
                  final m = withWeight[idx];
                  final w = m.weightKg?.toStringAsFixed(1) ?? '—';
                  final ds = m.date != null ? dateFmt.format(m.date!) : '';
                  return LineTooltipItem(
                    '$w كجم\n$ds',
                    const TextStyle(
                      color: _kDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
