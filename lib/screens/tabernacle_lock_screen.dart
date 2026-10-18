import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_constants.dart';
import '../utils/validators.dart';

/// Вход в «Скинию» — адрес /diary/unlock. Пароль из 4–6 цифр проверяется
/// только по формату: сверка с настоящим паролем появится в ЛР4–ЛР5.
class TabernacleLockScreen extends StatefulWidget {
  const TabernacleLockScreen({super.key});

  @override
  State<TabernacleLockScreen> createState() => _TabernacleLockScreenState();
}

class _TabernacleLockScreenState extends State<TabernacleLockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  void _open() {
    if (!_formKey.currentState!.validate()) return;
    // go: экран пароля уходит из стека, «назад» из Скинии ведёт в Дневник.
    context.go('/diary/tabernacle');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: scheme.secondaryContainer,
                      child: Icon(
                        Icons.lock_outline,
                        size: 40,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      'Скиния',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Личное место для молитв и размышлений. '
                      'Записи видны только вам.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 1.5),
                    TextFormField(
                      controller: _pinCtrl,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      // Поле не принимает ничего, кроме цифр, и не больше 6.
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      onFieldSubmitted: (_) => _open(),
                      decoration: const InputDecoration(
                        labelText: 'Пароль Скинии',
                        helperText: 'От 4 до 6 цифр',
                        prefixIcon: Icon(Icons.key_outlined),
                      ),
                      validator: Validators.tabernaclePin,
                    ),
                    const SizedBox(height: AppConstants.paddingLarge),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: _open,
                      icon: const Icon(Icons.lock_open),
                      label: const Text('Открыть'),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Забыли пароль Скинии?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
