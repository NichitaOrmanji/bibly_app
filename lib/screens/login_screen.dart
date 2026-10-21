import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/auth_api.dart';
import '../data/result.dart';
import '../utils/app_constants.dart';
import '../utils/validators.dart';

/// Экран входа и регистрации. Валидация полей — как в ЛР3; с ЛР5 верный
/// submit идёт на сервер ([AuthApi]): token сохраняется, затем — в приложение,
/// ошибка сервера — в SnackBar.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(); // только при регистрации

  /// Скрыт ли пароль — локальное состояние экрана (иконка-глаз).
  bool _obscure = true;

  /// Режим формы: вход или регистрация (сервер требует ещё и имя).
  bool _isRegister = false;

  /// Запрос в пути: кнопка погашена — двойной submit не уйдёт.
  bool _busy = false;

  @override
  void dispose() {
    // Кто создаёт контроллер, тот его и освобождает.
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (!_formKey.currentState!.validate()) return; // валидация ЛР3
    final auth = context.read<AuthApi>(); // read: действие в callback-е
    setState(() => _busy = true);
    final result = _isRegister
        ? await auth.register(
            _emailCtrl.text.trim(),
            _passwordCtrl.text,
            _nameCtrl.text.trim(),
          )
        : await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return; // экран мог закрыться, пока летел запрос
    setState(() => _busy = false);
    switch (result) {
      case Ok():
        // go, а не push: экран входа уходит из стека,
        // и «назад» не вернёт вошедшего пользователя на вход.
        context.go('/day');
      case Err(:final msg):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
    }
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
                    if (_isRegister) ...[
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: Validators.name,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                    ],
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
                      onFieldSubmitted: (_) => _submit(),
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
                    if (!_isRegister)
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
                      // null — кнопка погашена, пока запрос в пути.
                      onPressed: _busy ? null : _submit,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_isRegister ? 'Зарегистрироваться' : 'Войти'),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _isRegister = !_isRegister),
                      child: Text(
                        _isRegister
                            ? 'Уже есть аккаунт? Войдите'
                            : 'Нет аккаунта? Зарегистрируйтесь',
                      ),
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
