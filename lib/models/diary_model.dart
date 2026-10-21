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

  // ЛР5: поиск и ломти (страницы) — их делает сервер.
  static const pageSize = 20;
  String _search = ''; // фильтр переживает retry и pull-to-refresh
  int _page = 1;
  bool _hasMore = false;
  bool _loadingMore = false;
  String? _moreError;

  bool get isLoading => _loading;
  String? get error => _error;
  List<DiaryEntry> get entries => List.unmodifiable(_entries);

  /// Текущий поисковый запрос ('' — без фильтра).
  String get search => _search;

  /// Полная страница пришла — видимо, на сервере есть ещё.
  bool get hasMore => _hasMore;

  /// Следующая страница не загрузилась (хвост списка покажет «Повторить»).
  String? get moreError => _moreError;

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

  /// Первая страница. [search] — новый фильтр; null — оставить прежний
  /// (retry и «потянуть вниз» не сбрасывают поиск).
  Future<void> load({String? search}) async {
    _search = search ?? _search;
    _page = 1;
    _loading = true;
    _error = null;
    _moreError = null;
    notifyListeners();
    switch (await _repository.fetchAll(limit: pageSize, search: _search)) {
      case Ok(:final value):
        _entries = value;
        _hasMore = value.length == pageSize; // полная страница → есть ещё
      case Err(:final msg):
        _error = msg;
    }
    _loading = false;
    notifyListeners();
  }

  /// Следующая страница — приклеивается к уже загруженным.
  /// Вызывается из itemBuilder, то есть в разгар build: синхронный
  /// notifyListeners() здесь бросил бы «setState() called during build».
  /// Поэтому _loadingMore ставится БЕЗ извещения (spinner хвоста уже на
  /// экране через hasMore), а guard не даёт запросить страницу дважды.
  Future<void> loadMore() async {
    if (_loadingMore || _loading || !_hasMore || _moreError != null) return;
    _loadingMore = true;
    final result = await _repository.fetchAll(
      page: _page + 1,
      limit: pageSize,
      search: _search,
    );
    switch (result) {
      case Ok(:final value):
        _page += 1;
        _entries = [..._entries, ...value];
        _hasMore = value.length == pageSize;
      case Err(:final msg):
        _moreError = msg;
    }
    _loadingMore = false;
    notifyListeners();
  }

  /// «Повторить» в хвосте списка: снять ошибку и попросить страницу снова.
  /// Вызывается из кнопки (не из build), поэтому извещать можно сразу.
  Future<void> retryMore() {
    _moreError = null;
    final more = loadMore(); // _loadingMore = true — до перерисовки
    notifyListeners(); // хвост: вместо ошибки снова spinner
    return more;
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
