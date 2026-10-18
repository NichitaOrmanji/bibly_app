import 'package:flutter/foundation.dart';

import 'daily_task.dart';

/// Разделяемое состояние «План на день»: отметки выполнения читают
/// несколько экранов (прогресс в «Моём дне», бейдж на вкладке),
/// и оно переживает навигацию между вкладками.
///
/// Чистый Dart: ни одного widget-а (ChangeNotifier — из foundation).
class DayPlanModel extends ChangeNotifier {
  DayPlanModel(List<DailyTask> tasks) : _tasks = List.of(tasks);

  final List<DailyTask> _tasks;

  /// Наружу — только для чтения: изменить список можно лишь через
  /// методы модели, которые извещают подписчиков.
  List<DailyTask> get tasks => List.unmodifiable(_tasks);

  int get doneCount => _tasks.where((t) => t.isDone).length;
  int get remaining => _tasks.length - doneCount;

  void toggle(int id) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _tasks[i] = _tasks[i].copyWith(isDone: !_tasks[i].isDone);
    notifyListeners(); // весть уходит ко ВСЕМ подписчикам
  }
}
