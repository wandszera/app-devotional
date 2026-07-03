class RetentionMilestones {
  static const milestoneDays = [3, 7, 14, 30, 60, 100];

  static int? nextMilestone(int streak) {
    for (final item in milestoneDays) {
      if (item > streak) {
        return item;
      }
    }
    return null;
  }

  static int? latestMilestone(int streak) {
    for (final item in milestoneDays.reversed) {
      if (streak >= item) {
        return item;
      }
    }
    return null;
  }
}
