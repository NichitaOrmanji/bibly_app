import 'package:flutter/foundation.dart';

import '../data/diary_repository.dart';
import '../data/result.dart';
import 'diary_entry.dart';

/// Записи дневника — главная сущность темы. Их читают Дневник, Скиния,
/// детали записи и статистика профиля; пишут форма и удаление.
class DiaryModel extends ChangeNotifier {
  DiaryModel(this._repository);

  final DiaryRepository _repository; // интерфейс: источник модели неизвестен

  bool _loading = false;
  String? _error;
  List<DiaryEntry> _entries = const [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<DiaryEntry> get entries => List.unmodifiable(_entries);

  /// Открытые записи — для «Дневника», личные — для «Скинии».
  List<DiaryEntry> get publicEntries =>
      List.unmodifiable(_entries.where((e) => !e.isPrivate));
  List<DiaryEntry> get privateEntries =>
      List.unmodifiable(_entries.where((e) => e.isPrivate));

  /// Поиск в загруженном списке; null — записи нет (или ещё не загружено).
  DiaryEntry? byId(int id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    switch (await _repository.fetchAll()) {
      case Ok(:final value):
        _entries = value;
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  /// Мутации: вердикт хранилища → изменение → извещение.
  /// null — успех, иначе сообщение для экрана.
  Future<String?> add(DiaryEntry draft) async {
    switch (await _repository.create(draft)) {
      case Ok(:final value):
        _entries = [value, ..._entries]; // с id, полученным от хранилища
        notifyListeners(); // список, Скиния, профиль — узнают все
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> update(DiaryEntry entry) async {
    switch (await _repository.update(entry)) {
      case Ok(:final value):
        _entries = [
          for (final e in _entries)
            if (e.id == value.id) value else e,
        ];
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> remove(int id) async {
    switch (await _repository.delete(id)) {
      case Ok():
        _entries = _entries.where((e) => e.id != id).toList();
        notifyListeners();
        return null;
      case Err(:final msg):
        return msg;
    }
  }
}
