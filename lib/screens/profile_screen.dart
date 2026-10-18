import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock/mock_network.dart';
import '../models/diary_model.dart';
import '../models/profile_model.dart';
import '../models/user_profile.dart';
import '../utils/app_constants.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_view.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';

/// Пункт настроек: подпись — часть интерфейса, значение — из профиля.
class _Setting {
  final IconData icon;
  final String title;
  final String? value;

  /// null — обычный пункт со стрелкой, true/false — переключатель.
  final bool? switchOn;

  const _Setting(this.icon, this.title, {this.value, this.switchOn});
}

List<_Setting> _settingsOf(UserProfile p) => [
  _Setting(Icons.translate, 'Перевод Библии', value: p.translation),
  _Setting(Icons.text_fields, 'Размер текста', value: p.textSize),
  _Setting(
    Icons.notifications_outlined,
    'Напоминание о чтении',
    value: p.reminderTime,
    switchOn: p.reminderOn,
  ),
  const _Setting(
    Icons.dark_mode_outlined,
    'Тёмная тема',
    value: 'как в системе',
  ),
  const _Setting(Icons.lock_outline, 'Пароль Скинии', value: 'изменить'),
  _Setting(
    Icons.public,
    'Делиться записями с группой',
    switchOn: p.shareWithGroup,
  ),
  _Setting(Icons.language, 'Язык приложения', value: p.language),
  const _Setting(
    Icons.info_outline,
    'О приложении',
    value: 'версия ${AppConstants.appVersion}',
  ),
];

/// Выход: сначала подтверждение, затем go на вход.
Future<void> _logout(BuildContext context) async {
  final ok = await showConfirmDialog(
    context,
    title: 'Выйти из аккаунта?',
    message: 'Чтобы снова открыть дневник и планы, нужно будет войти.',
    confirmLabel: 'Да, выйти',
  );
  // После await пользуемся context только если экран ещё на месте.
  if (ok && context.mounted) {
    context.go('/login'); // go: раздел с вкладками целиком уходит из стека
  }
}

/// «Профиль» — данные пользователя ([ProfileModel]), статистика
/// (число записей — из [DiaryModel]) и настройки.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ProfileModel>(); // watch в build

    final Widget body;
    if (model.isLoading) {
      body = const Center(child: CircularProgressIndicator()); // 1) грузится
    } else if (model.error != null || model.profile == null) {
      body = ErrorView(
        // 2) упало
        message: model.error ?? 'Не удалось загрузить профиль',
        onRetry: () => context.read<ProfileModel>().load(),
      );
    } else {
      body = _ProfileContent(profile: model.profile!); // 3) данные
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: model.profile == null
                ? null
                : () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: body,
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserProfile profile;

  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Число записей — разделяемое состояние Дневника: добавили или
    // удалили запись на другом экране — плитка обновится сама.
    final diary = context.watch<DiaryModel>();
    final entriesCount = diary.isLoading || diary.error != null
        ? '…'
        : '${diary.entries.length}';

    return ListView(
      padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
      children: [
        const SizedBox(height: AppConstants.paddingSmall),
        Center(child: InitialsAvatar(name: profile.name, radius: 44)),
        const SizedBox(height: AppConstants.paddingMedium),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        Text(
          '${profile.email} · ${profile.memberSince}',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        if (profile.about.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.paddingLarge,
              AppConstants.paddingSmall,
              AppConstants.paddingLarge,
              0,
            ),
            child: Text(
              profile.about,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: AppConstants.paddingLarge),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          child: Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.local_fire_department_outlined,
                  value: '${profile.streakDays}',
                  label: 'дней подряд',
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: StatTile(
                  icon: Icons.menu_book_outlined,
                  value: '${profile.chaptersRead}',
                  label: 'глав прочитано',
                ),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: StatTile(
                  icon: Icons.history_edu_outlined,
                  value: entriesCount,
                  label: 'записей',
                ),
              ),
            ],
          ),
        ),
        const SectionHeader(title: 'Демонстрация'),
        const _CrashSwitch(),
        const SectionHeader(title: 'Настройки'),
        for (final s in _settingsOf(profile))
          ListTile(
            leading: Icon(s.icon, color: scheme.onSurfaceVariant),
            title: Text(s.title),
            subtitle: s.value == null ? null : Text(s.value!),
            trailing: s.switchOn == null
                ? Icon(Icons.chevron_right, color: scheme.outline)
                : Switch(value: s.switchOn!, onChanged: (_) {}),
            onTap: () {},
          ),
        const SizedBox(height: AppConstants.paddingMedium),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ),
      ],
    );
  }
}

/// Переключатель аварии — ЕДИНСТВЕННОЕ место UI, которому позволено
/// знать о mock-е: леса демонстрации, исчезают на L5 вместе с ним.
/// Положение переключателя — эфемерное состояние: bool в State + setState.
class _CrashSwitch extends StatefulWidget {
  const _CrashSwitch();

  @override
  State<_CrashSwitch> createState() => _CrashSwitchState();
}

class _CrashSwitchState extends State<_CrashSwitch> {
  late bool _on = context.read<MockNetwork>().simulateError;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.wifi_off_outlined),
      title: const Text('Симулировать сбой сети'),
      subtitle: const Text('Все запросы к хранилищу будут падать'),
      value: _on,
      onChanged: (value) {
        setState(() => _on = value);
        context.read<MockNetwork>().simulateError = value; // read в callback-е
      },
    );
  }
}
