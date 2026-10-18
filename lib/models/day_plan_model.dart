import 'package:flutter/foundation.dart';

import '../data/daily_repository.dart';
import '../data/result.dart';
import 'daily_task.dart';
import 'verse.dart';

/// Разделяемое состояние «Мой день»: стих дня и отметки плана читают
/// несколько экранов (прогресс в «Моём дне», бейдж на вкладке),
/// и оно переживает навигацию между вкладками.
///
/// Чистый Dart: ни одного widget-а (ChangeNotifier — из foundation).
class DayPlanModel extends ChangeNotifier {
  DayPlanModel(this._repository); // простой DI: хранилище — в конструктор

  final DailyRepository _repository; // тип — ИНТЕРФЕЙС, а не mock

  bool _loading = false;
  String? _error;
  String _dateLabel = '';
  Verse? _verse;
  List<DailyTask> _tasks = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  String get dateLabel => _dateLabel;
  Verse? get verseOfDay => _verse;

  /// Наружу — только для чтения: изменить список можно лишь через
  /// методы модели, которые извещают подписчиков.
  List<DailyTask> get tasks => List.unmodifiable(_tasks);

  int get doneCount => _tasks.where((t) => t.isDone).length;
  int get remaining => _tasks.length - doneCount;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners(); // подписчики входят в состояние «грузится»
    switch (await _repository.fetchToday()) {
      case Ok(:final value):
        _dateLabel = value.dateLabel;
        _verse = value.verseOfDay;
        _tasks = value.tasks;
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners(); // …и выходят: с данными или с ошибкой — никогда молча
  }

  /// Отметить / снять отметку. null — успех, иначе текст ошибки
  /// (та же конвенция, что у validator).
  Future<String?> toggle(int id) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return 'Пункт плана не найден';
    switch (await _repository.setTaskDone(id, !_tasks[i].isDone)) {
      case Ok(:final value):
        _tasks = [
          for (final t in _tasks)
            if (t.id == id) value else t,
        ];
        notifyListeners(); // весть уходит ко ВСЕМ подписчикам
        return null;
      case Err(:final msg):
        return msg; // состояние нетронуто — экран решает, что показать
    }
  }
}
