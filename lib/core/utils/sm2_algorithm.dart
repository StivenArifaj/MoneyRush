// SM-2 spaced repetition algorithm (same system as Anki / Duolingo).
// Returns updated ease factor, interval in days, repetition count, and next review date.
class SM2Result {
  final double easeFactor;
  final int intervalDays;
  final int repetitionCount;
  final DateTime nextReviewAt;

  const SM2Result({
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitionCount,
    required this.nextReviewAt,
  });
}

class SM2Algorithm {
  // quality: 0 = total failure, 5 = perfect recall
  // Map was_optimal to quality: optimal=4, not optimal=1
  static SM2Result calculate({
    required double currentEaseFactor,
    required int currentIntervalDays,
    required int repetitionCount,
    required bool wasOptimal,
  }) {
    final quality = wasOptimal ? 4 : 1;

    double newEaseFactor =
        currentEaseFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    newEaseFactor = newEaseFactor.clamp(1.3, 2.5);

    int newInterval;
    int newRepCount;

    if (quality < 3) {
      // Failed — reset to day 1
      newInterval = 1;
      newRepCount = 0;
    } else {
      newRepCount = repetitionCount + 1;
      if (repetitionCount == 0) {
        newInterval = 1;
      } else if (repetitionCount == 1) {
        newInterval = 6;
      } else {
        newInterval = (currentIntervalDays * newEaseFactor).round();
      }
    }

    final nextReview =
        DateTime.now().add(Duration(days: newInterval));

    return SM2Result(
      easeFactor: newEaseFactor,
      intervalDays: newInterval,
      repetitionCount: newRepCount,
      nextReviewAt: nextReview,
    );
  }
}
