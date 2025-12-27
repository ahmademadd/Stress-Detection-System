abstract class StressSummaryRepository {
  Stream<Map<String, int>> watchDailyStressCounts({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<void> incrementToday();
}
