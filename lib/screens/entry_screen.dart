import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/diary_model.dart';
import '../utils/app_constants.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_view.dart';

/// Удаление: подтверждение → SnackBar → назад к списку.
/// Запись на самом деле не исчезает — состояние появится в ЛР4.
Future<void> _delete(BuildContext context, String title) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Удалить запись?',
    message: '«$title» будет удалена без возможности восстановления.',
    confirmLabel: 'Удалить',
  );
  if (ok && context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Запись «$title» удалена')));
    context.pop();
  }
}

/// Запись дневника — адреса /diary/:id и /diary/tabernacle/:id.
/// Экран получает id из адреса и ищет запись через [DiaryModel];
/// объект через extra не передаётся.
class EntryScreen extends StatelessWidget {
  final int id;

  const EntryScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Поиск через модель (L4), а не в mock-данных (L3).
    final model = context.watch<DiaryModel>();
    final entry = model.byId(id);
    if (entry == null) {
      // У null два смысла: список ещё грузится / загружен, но id нет
      // (старая ссылка или удалённая запись) — не вечный spinner.
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: model.isLoading
              ? const CircularProgressIndicator()
              : model.error != null
              ? ErrorView(
                  message: model.error!,
                  onRetry: () => context.read<DiaryModel>().load(),
                )
              : const Text('Запись не существует'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.isPrivate ? 'Скиния' : 'Запись'),
        actions: [
          IconButton(
            tooltip: 'Удалить',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(context, entry.title),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          Row(
            children: [
              Icon(
                entry.isPrivate ? Icons.lock : Icons.public,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                '${entry.dateLabel} · '
                '${entry.isPrivate ? 'видна только вам' : 'видна группе'}',
                style: textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(entry.title, style: textTheme.headlineSmall),
          if (entry.verseReference != null) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: Icon(Icons.menu_book, color: scheme.primary),
                label: Text(entry.verseReference!),
              ),
            ),
          ],
          const SizedBox(height: AppConstants.paddingMedium),
          Text(entry.text, style: textTheme.bodyLarge?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}
