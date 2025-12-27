import '../model/stress_event.dart';

abstract class StressEventRepository {
  Future<void> saveStressEvent(StressEvent event);
  Future<List<StressEvent>> getStressEventsByDay(DateTime day);
}
