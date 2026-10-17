import 'package:flutter/material.dart';

import '../utils/app_constants.dart';
import 'tabernacle_screen.dart';

/// Вход в «Скинию» — статический макет (ЛР2): поле пароля без проверки.
/// Настоящая проверка пароля появится вместе с состоянием и бэкендом.
class TabernacleLockScreen extends StatelessWidget {
  const TabernacleLockScreen({super.key});

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
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Пароль Скинии',
                      prefixIcon: Icon(Icons.key_outlined),
                      suffixIcon: Icon(Icons.visibility_off_outlined),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TabernacleScreen(),
                      ),
                    ),
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
    );
  }
}
