import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/boxes.dart';

const _weeklyTargetMinutes = 75; // WHO vigorous recommendation (dual strength+vig)

final hiitProgressProvider = StreamProvider<double>((ref) {
  return ref.watch(workoutSessionsProvider.stream).map((sessions) {
    final now = DateTime.now();
    // Get start of current week (Monday = 1, Sunday = 7)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)).copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0,
    );

    int totalWorkSec = 0;
    for (final s in sessions) {
      if (s.start.isBefore(startOfWeek)) continue;
      for (final interval in s.intervals) {
        // Validate interval to prevent corrupted data
        if (interval.workSec > 0 && interval.workSec < 3600) { // Max 1 hour per interval
          totalWorkSec += interval.workSec;
        }
      }
    }
    final minutes = totalWorkSec / 60;
    return (minutes / _weeklyTargetMinutes).clamp(0.0, 1.0);
  });
}); 