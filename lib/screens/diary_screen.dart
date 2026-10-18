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
      appBar: AppBar(title: const Text('Дневник')),
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
          // 1 — заголовок, дальше — записи дневника.
          : RefreshIndicator(
              onRefresh: () => context.read<DiaryModel>().load(),
              child: ListView.builder(
                // Нижний отступ, чтобы FAB не закрывал последнюю запись.
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: entries.length + 2,
                itemBuilder: (context, i) {
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
                      title: 'Мои записи',
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
