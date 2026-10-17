import 'package:flutter/material.dart';

import '../utils/app_constants.dart';
import 'main_shell.dart';

/// Экран входа — строго статический макет (L2):
/// без Form, без валидации, без логики аутентификации.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                  const TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      hintText: 'name@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                    ),
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
                    // Только переход дальше, чтобы не блокировать демонстрацию.
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainShell()),
                    ),
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
    );
  }
}
