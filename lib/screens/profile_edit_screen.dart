import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';

/// Редактирование профиля — адрес /profile/edit.
/// Поля заполнены из [ProfileModel]; валидный submit пишет через модель
/// → хранилище, и имя меняется в «Профиле» и в приветствии «Моего дня».
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileModel>().profile;
    _nameCtrl.text = p?.name ?? '';
    _emailCtrl.text = p?.email ?? '';
    _phoneCtrl.text = p?.phone ?? '';
    _aboutCtrl.text = p?.about ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final model = context.read<ProfileModel>();
    final current = model.profile;
    if (current == null) return;
    setState(() => _saving = true);
    final error = await model.update(
      current.copyWith(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text,
        about: _aboutCtrl.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error))); // данные остаются
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          children: [
            TextFormField(
              controller: _nameCtrl,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Имя и фамилия',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: Validators.name,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: Validators.email,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              // Телефон — только цифры, не больше 9.
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: const InputDecoration(
                labelText: 'Телефон (необязательно)',
                hintText: '069123456',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: Validators.phone,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            TextFormField(
              controller: _aboutCtrl,
              textInputAction: TextInputAction.done,
              maxLength: 120,
              decoration: const InputDecoration(
                labelText: 'О себе (необязательно)',
                prefixIcon: Icon(Icons.short_text),
              ),
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
