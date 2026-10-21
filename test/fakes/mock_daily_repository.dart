import 'package:bibly_app/models/daily_task.dart';
import 'package:bibly_app/models/day_plan.dart';
import 'package:bibly_app/data/daily_repository.dart';

import 'mock_data.dart';

import 'package:bibly_app/data/result.dart';

import 'mock_network.dart';

/// «Мой день» в памяти: стих дня и отметки плана.
class MockDailyRepository implements DailyRepository {
  MockDailyRepository(this._net);

  final MockNetwork _net;
  final List<DailyTask> _tasks = List.of(MockData.todayPlan);

  @override
  Future<Result<DayPlan>> fetchToday() async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    return Ok(
      DayPlan(
        dateLabel: MockData.todayLabel,
        verseOfDay: MockData.verseOfDay,
        tasks: List.of(_tasks),
      ),
    );
  }

  @override
  Future<Result<DailyTask>> setTaskDone(int taskId, bool done) async {
    if (!await _net.roundTrip()) return const Err(MockNetwork.errNetwork);
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return const Err('Пункт плана не существует');
    _tasks[i] = _tasks[i].copyWith(isDone: done);
    return Ok(_tasks[i]);
  }
}
