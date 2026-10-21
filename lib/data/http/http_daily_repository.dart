import '../../models/daily_task.dart';
import '../../models/day_plan.dart';
import '../daily_repository.dart';
import '../result.dart';
import 'api_client.dart';

/// «Мой день» на сервере: план дня общий, отметки — свои у пользователя.
class HttpDailyRepository implements DailyRepository {
  HttpDailyRepository(this._api);

  final ApiClient _api;

  /// GET /plans/today → {dateLabel, verseOfDay, tasks}.
  @override
  Future<Result<DayPlan>> fetchToday() => _api.get(
    '/plans/today',
    (j) => DayPlan.fromJson(j as Map<String, dynamic>),
  );

  /// PATCH /plans/today/tasks/{id} {isDone} → обновлённый пункт.
  @override
  Future<Result<DailyTask>> setTaskDone(int taskId, bool done) => _api.patch(
    '/plans/today/tasks/$taskId',
    {'isDone': done},
    (j) => DailyTask.fromJson(j as Map<String, dynamic>),
  );
}
