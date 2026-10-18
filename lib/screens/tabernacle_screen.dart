import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/diary_entry.dart';
import '../models/diary_model.dart';
import '../utils/app_constants.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/diary_entry_card.dart';
import '../widgets/error_view.dart';

/// «Скиния» — приватные записи, открываются после ввода пароля.
class TabernacleScreen extends StatelessWidget {
  const TabernacleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final model = context.watch<DiaryModel>();
    final entries = model.privateEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Скиния'),
        actions: [
          IconButton(
            tooltip: 'Закрыть Скинию',
            icon: const Icon(Icons.lock),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/diary/new?place=tabernacle'),
        icon: const Icon(Icons.history_edu),
        label: const Text('Личная запись'),
      ),
      body: model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : model.error != null
          ? ErrorView(
              message: model.error!,
              onRetry: () => context.read<DiaryModel>().load(),
            )
          // Элемент 0 — подсказка о приватности, дальше — записи.
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: entries.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    child: Row(
                      children: [
                        Icon(
                          Icons.visibility_off,
                          size: 18,
                          color: scheme.secondary,
                        ),
                        const SizedBox(width: AppConstants.paddingSmall),
                        Expanded(
                          child: Text(
                            'Эти записи видны только вам',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final entry = entries[i - 1];
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
                    onTap: () => context.push('/diary/tabernacle/${entry.id}'),
                  ),
                );
              },
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
