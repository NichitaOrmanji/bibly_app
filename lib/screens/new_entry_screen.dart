import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_constants.dart';
import '../utils/validators.dart';

/// Куда сохраняется запись: в открытый Дневник или в приватную Скинию.
enum EntryPlace { diary, tabernacle }

/// Новая запись — адрес /diary/new (открывается push-ем, закрывается pop-ом).
/// Необязательные query-параметры заполняют поля заранее:
/// /diary/new?verse=Ин%203 — из «Чтения главы», ?place=tabernacle — из Скинии.
/// Форма проверяет данные, но никуда их не сохраняет — это ЛР4.
class NewEntryScreen extends StatefulWidget {
  final String? initialVerse;
  final EntryPlace? initialPlace;

  const NewEntryScreen({super.key, this.initialVerse, this.initialPlace});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _verseCtrl = TextEditingController();
  final _textCtrl = TextEditingController();
  EntryPlace? _place;

  @override
  void initState() {
    super.initState();
    _verseCtrl.text = widget.initialVerse ?? '';
    _place = widget.initialPlace;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _verseCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return; // ошибки уже на экране
    final where = _place == EntryPlace.tabernacle ? 'Скинию' : 'Дневник';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Запись «${_titleCtrl.text.trim()}» сохранена в $where'),
      ),
    );
    context.pop(); // открыто push-ем → закрывается pop-ом
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая запись')),
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
              validator: Validators.verseReference,
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
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
