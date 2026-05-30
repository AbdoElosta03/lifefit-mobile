import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/models/progress/personal_record.dart';

class PersonalRecordTile extends StatelessWidget {
  final PersonalRecord record;
  final bool compact;

  const PersonalRecordTile({
    super.key,
    required this.record,
    this.compact = false,
  });

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final w = record.weight;
    final reps = record.reps;
    final e1 = record.estimatedOneRm;
    final at = record.recordedAt;
    final muscles = record.exercise?.muscles;

    final wxr = (w != null && reps != null)
        ? '${_fmtNum(w)} × $reps'
        : (w != null ? _fmtNum(w) : (reps != null ? '$reps عدّة' : '—'));

    // Record card container.
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 10 : 12),
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Exercise name.
          Text(
            record.displayExerciseName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: compact ? 14 : 15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
          if (muscles != null && muscles.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            // Muscles list.
            Text(
              muscles,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ],
          SizedBox(height: compact ? 8 : 10),
          // Date and record values row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Recorded date.
              Text(
                at != null ? _dateFmt.format(at.toLocal()) : '—',
                style: TextStyle(fontSize: compact ? 11 : 12, color: Colors.grey),
              ),
              // Weight/reps and 1RM column.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Weight x reps label.
                  Text(
                    wxr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  if (e1 != null)
                    // Estimated 1RM label.
                    Text(
                      'تقدير 1RM: ${_fmtNum(e1)} كجم',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtNum(double n) {
    if (n == n.roundToDouble()) return n.toStringAsFixed(0);
    return n.toStringAsFixed(2);
  }
}
