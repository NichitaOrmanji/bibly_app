import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/diary_entry.dart';
import '../models/diary_model.dart';
import '../utils/app_constants.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/diary_entry_card.dart';
import '../widgets/error_view.dart';
import '../widgets/section_header.dart';

/// «Дневник» — обычные записи и вход в «Скинию» (приватные записи).
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final model = context.watch<DiaryModel>(); // watch в build
    final entries = model.publicEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Дневник'),
        // Поиск над списком — в AppBar, чтобы поле не пропадало,
        // пока список грузится. Ищет СЕРВЕР.
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(64),
          child: _SearchField(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/diary/new'),
        icon: const Icon(Icons.history_edu),
        label: const Text('Новая запись'),
      ),
      body: model.isLoading
          ? const Center(child: CircularProgressIndicator()) // 1) грузится
          : model.error != null
          ? ErrorView(
              // 2) упало
              message: model.error!,
              onRetry: () => context.read<DiaryModel>().load(),
            )
          // 3) данные. Свайп вниз — обновить список из хранилища.
          // ListView.builder: элемент 0 — вход в Скинию,
          // 1 — заголовок, дальше — записи дневника, а если на сервере
          // есть ещё — хвост, который просит следующую страницу.
          : RefreshIndicator(
              onRefresh: () => context.read<DiaryModel>().load(),
              child: ListView.builder(
                // Нижний отступ, чтобы FAB не закрывал последнюю запись.
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: entries.length + 2 + (model.hasMore ? 1 : 0),
                itemBuilder: (context, i) {
                  if (i == entries.length + 2) {
                    return _ListTail(error: model.moreError);
                  }
                  if (i == 0) {
                    return Card(
                      elevation: 0,
                      color: scheme.secondaryContainer,
                      margin: const EdgeInsets.fromLTRB(
                        AppConstants.paddingMedium,
                        AppConstants.paddingSmall,
                        AppConstants.paddingMedium,
                        0,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingMedium,
                          vertical: AppConstants.paddingSmall,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: scheme.secondary,
                          child: Icon(Icons.lock, color: scheme.onSecondary),
                        ),
                        title: Text(
                          'Скиния',
                          style: TextStyle(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Личные записи · ${model.privateEntries.length} · '
                          'вход по паролю',
                          style: TextStyle(color: scheme.onSecondaryContainer),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: scheme.onSecondaryContainer,
                        ),
                        onTap: () => context.push('/diary/unlock'),
                      ),
                    );
                  }
                  if (i == 1) {
                    return SectionHeader(
                      title: model.search.isEmpty
                          ? 'Мои записи'
                          : 'Найдено по «${model.search}»',
                      trailing: '${entries.length}',
                    );
                  }
                  final entry = entries[i - 2];
                  // Свайп удаляет запись. Ключ — идентичность из данных
                  // (ValueKey(id)), не UniqueKey: Flutter должен знать,
                  // какая именно строка ушла.
                  return Dismissible(
                    key: ValueKey(entry.id),
                    direction: DismissDirection.endToStart,
                    background: const _DeleteBackground(),
                    confirmDismiss: (_) => _confirmDelete(context, entry),
                    child: DiaryEntryCard(
                      entry: entry,
                      // push + id в адресе: детали сами найдут запись.
                      onTap: () => context.push('/diary/${entry.id}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

/// Поле поиска. Свой State — ради контроллера текста; запрос уходит
/// на сервер по Enter (а не на каждую букву).
class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    // Начальный текст — текущий фильтр модели (один раз, не в build).
    _ctrl = TextEditingController(text: context.read<DiaryModel>().search);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _clear() {
    _ctrl.clear();
    setState(() {}); // спрятать крестик
    context.read<DiaryModel>().load(search: '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        0,
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
      ),
      child: TextField(
        controller: _ctrl,
        textInputAction: TextInputAction.search,
        onChanged: (_) => setState(() {}), // показать/спрятать крестик
        onSubmitted: (q) => context.read<DiaryModel>().load(search: q.trim()),
        decoration: InputDecoration(
          hintText: 'Поиск по записям',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _ctrl.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Сбросить поиск',
                  icon: const Icon(Icons.close),
                  onPressed: _clear,
                ),
          isDense: true,
        ),
      ),
    );
  }
}

/// Хвост списка: просит следующую страницу и показывает маленький spinner;
/// если страница не пришла — сообщение и «Повторить».
class _ListTail extends StatelessWidget {
  const _ListTail({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Text(error!, textAlign: TextAlign.center),
            TextButton.icon(
              onPressed: () => context.read<DiaryModel>().retryMore(),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      );
    }
    // Хвост на экране — значит, пользователь долистал: просим ещё.
    // read, а не watch: это действие; guard в модели не даст дублей.
    context.read<DiaryModel>().loadMore();
    return const Padding(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      child: Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Подтверждение и удаление по свайпу. true — строку можно убрать:
/// запись уже удалена в хранилище и модели.
Future<bool> _confirmDelete(BuildContext context, DiaryEntry entry) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Удалить запись?',
    message: '«${entry.title}» будет удалена без возможности восстановления.',
    confirmLabel: 'Удалить',
  );
  if (!ok || !context.mounted) return false;
  final error = await context.read<DiaryModel>().remove(entry.id);
  if (!context.mounted) return error == null;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(error ?? 'Запись «${entry.title}» удалена')),
  );
  return error == null;
}

/// Красный фон под карточкой при свайпе.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppConstants.paddingLarge),
      color: scheme.errorContainer,
      child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
    );
  }
}
