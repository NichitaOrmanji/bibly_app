import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';

/// Редактирование профиля — адрес /profile/edit.
/// Поля заполнены текущими mock-данными; после проверки — SnackBar и pop.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: MockData.userFullName);
  final _emailCtrl = TextEditingController(text: MockData.userEmail);
  final _phoneCtrl = TextEditingController();
  final _aboutCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
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
