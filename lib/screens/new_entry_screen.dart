import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/bible_model.dart';
import '../models/diary_entry.dart';
import '../models/diary_model.dart';
import '../utils/app_constants.dart';
import '../utils/date_labels.dart';
import '../utils/validators.dart';

/// Куда сохраняется запись: в открытый Дневник или в приватную Скинию.
enum EntryPlace { diary, tabernacle }

/// Форма записи:
/// - новая — адрес /diary/new (push → pop); query-параметры заполняют
///   поля заранее: ?verse=Ин 3 (из «Чтения главы»), ?place=tabernacle;
/// - редактирование — /diary/:id/edit и /diary/tabernacle/:id/edit.
/// Валидный submit ПИШЕТ через модель → хранилище; список обновляется сам.
class NewEntryScreen extends StatefulWidget {
  final String? initialVerse;
  final EntryPlace? initialPlace;

  /// id редактируемой записи; null — новая запись.
  final int? entryId;

  const NewEntryScreen({
    super.key,
    this.initialVerse,
    this.initialPlace,
    this.entryId,
  });

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _verseCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  EntryPlace? _place;

  /// Редактируемая запись (null — новая).
  DiaryEntry? _editing;

  /// «Запрос» в пути — эфемерное состояние: блокирует повторное нажатие.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.entryId != null) {
      _editing = context.read<DiaryModel>().byId(widget.entryId!);
    }
    final e = _editing;
    _titleCtrl.text = e?.title ?? '';
    _verseCtrl.text = e?.verseReference ?? widget.initialVerse ?? '';
    _textCtrl.text = e?.text ?? '';
    _place = e == null
        ? widget.initialPlace
        : (e.isPrivate ? EntryPlace.tabernacle : EntryPlace.diary);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _verseCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return; // валидация L3, нетронута

    final verse = _verseCtrl.text.trim();
    final draft = DiaryEntry(
      // Временный id 0 — настоящую идентичность даст хранилище (на L5 — сервер).
      id: _editing?.id ?? 0,
      title: _titleCtrl.text.trim(),
      text: _textCtrl.text.trim(),
      dateLabel: _editing?.dateLabel ?? shortDateLabel(DateTime.now()),
      verseReference: verse.isEmpty ? null : verse,
      isPrivate: _place == EntryPlace.tabernacle,
    );

    setState(() => _saving = true);
    final model = context.read<DiaryModel>(); // read: действие
    final error = _editing == null
        ? await model.add(draft)
        : await model.update(draft);
    if (!mounted) return; // экран может умереть, пока запрос летит
    setState(() => _saving = false);

    if (error != null) {
      // Данные остаются в полях — можно повторить.
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final where = draft.isPrivate ? 'Скинию' : 'Дневник';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _editing == null
              ? 'Запись «${draft.title}» сохранена в $where'
              : 'Запись «${draft.title}» обновлена',
        ),
      ),
    );
    context.pop(); // список позади УЖЕ обновлён — без единого лишнего вызова
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing == null ? 'Новая запись' : 'Редактировать'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          children: [
            TextFormField(
              controller: _titleCtrl,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                prefixIcon: Icon(Icons.title),
              ),
              validator: Validators.entryTitle,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            TextFormField(
              controller: _verseCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Ссылка на стих (необязательно)',
                hintText: 'Ин 3:16',
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
              // Книги — из модели; validator — callback, поэтому read.
              validator: (v) => Validators.verseReference(
                v,
                context.read<BibleModel>().books,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: _textCtrl,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              minLines: 5,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Текст записи',
                alignLabelWithHint: true,
              ),
              validator: Validators.entryText,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            DropdownButtonFormField<EntryPlace>(
              initialValue: _place,
              decoration: const InputDecoration(
                labelText: 'Куда сохранить',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
              items: const [
                DropdownMenuItem(
                  value: EntryPlace.diary,
                  child: Text('Дневник — видна группе'),
                ),
                DropdownMenuItem(
                  value: EntryPlace.tabernacle,
                  child: Text('Скиния — только для меня'),
                ),
              ],
              onChanged: (value) => setState(() => _place = value),
              // У поля выбора тоже есть validator.
              validator: (value) =>
                  value == null ? 'Выберите, куда сохранить запись' : null,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Сохраняем…' : 'Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
