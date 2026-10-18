import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_constants.dart';
import '../utils/validators.dart';

/// Экран входа (ЛР3): локальная валидация полей, без реальной
/// аутентификации — любые e-mail и пароль, прошедшие проверку, впускают.
/// Проверка по пользователю появится в ЛР5 вместе с бэкендом.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  /// Скрыт ли пароль — локальное состояние экрана (иконка-глаз).
  bool _obscure = true;

  @override
  void dispose() {
    // Кто создаёт контроллер, тот его и освобождает.
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return; // ошибки уже на экране
    // go, а не push: экран входа уходит из стека,
    // и «назад» не вернёт вошедшего пользователя на вход.
    context.go('/day');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          // Прокрутка, чтобы клавиатура не вызывала переполнение.
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
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 40,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      'Тихое время с Богом — каждый день',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingLarge * 1.5),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: AppConstants.paddingMedium),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Показать' : 'Скрыть',
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Забыли пароль?'),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: _login,
                      child: const Text('Войти'),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Нет аккаунта? Зарегистрируйтесь'),
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
