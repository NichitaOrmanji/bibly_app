import '../models/daily_task.dart';
import '../models/day_plan.dart';
import 'result.dart';

/// Контракт хранилища «Моего дня».
///   fetchToday()           → GET   /plans/today
///   setTaskDone(id, done)  → PATCH /plans/today/tasks/{id}
abstract class DailyRepository {
  Future<Result<DayPlan>> fetchToday();
  Future<Result<DailyTask>> setTaskDone(int taskId, bool done);
}
