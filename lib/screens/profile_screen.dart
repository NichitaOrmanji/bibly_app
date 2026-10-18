import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../utils/app_constants.dart';
import '../widgets/initials_avatar.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';

/// Пункт настроек. Данные нужны только этому экрану,
/// поэтому они лежат здесь, а не в mock_data.dart.
class _Setting {
  final IconData icon;
  final String title;
  final String? value;

  /// null — обычный пункт со стрелкой, true/false — переключатель.
  final bool? switchOn;

  const _Setting(this.icon, this.title, {this.value, this.switchOn});
}

const List<_Setting> _settings = [
  _Setting(Icons.translate, 'Перевод Библии', value: 'Синодальный'),
  _Setting(Icons.text_fields, 'Размер текста', value: 'Средний'),
  _Setting(
    Icons.notifications_outlined,
    'Напоминание о чтении',
    value: 'каждый день в 07:30',
    switchOn: true,
  ),
  _Setting(
    Icons.dark_mode_outlined,
    'Тёмная тема',
    value: 'как в системе',
    switchOn: false,
  ),
  _Setting(Icons.lock_outline, 'Пароль Скинии', value: 'установлен'),
  _Setting(Icons.public, 'Делиться записями с группой', switchOn: true),
  _Setting(Icons.language, 'Язык приложения', value: 'Русский'),
  _Setting(Icons.info_outline, 'О приложении', value: 'версия 0.2.0'),
];

/// «Профиль» — данные пользователя, статистика и настройки.
/// Переключатели статические: значения берутся из списка выше.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final entriesCount =
        MockData.diaryEntries.length + MockData.tabernacleEntries.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            tooltip: 'Редактировать',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppConstants.paddingLarge),
        children: [
          const SizedBox(height: AppConstants.paddingSmall),
          const Center(
            child: InitialsAvatar(name: MockData.userFullName, radius: 44),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            MockData.userFullName,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          Text(
            '${MockData.userEmail} · ${MockData.memberSince}',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: StatTile(
                    icon: Icons.local_fire_department_outlined,
                    value: '${MockData.streakDays}',
                    label: 'дней подряд',
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                const Expanded(
                  child: StatTile(
                    icon: Icons.menu_book_outlined,
                    value: '${MockData.chaptersRead}',
                    label: 'глав прочитано',
                  ),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: StatTile(
                    icon: Icons.history_edu_outlined,
                    value: '$entriesCount',
                    label: 'записей',
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Настройки'),
          for (final s in _settings)
            ListTile(
              leading: Icon(s.icon, color: scheme.onSurfaceVariant),
              title: Text(s.title),
              subtitle: s.value == null ? null : Text(s.value!),
              trailing: s.switchOn == null
                  ? Icon(Icons.chevron_right, color: scheme.outline)
                  // Пустой onChanged: переключатель выглядит активным,
                  // но значение не меняется (состояние — в ЛР4).
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
              // go: раздел с вкладками целиком уходит из стека.
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.logout),
              label: const Text('Выйти'),
            ),
          ),
        ],
      ),
    );
  }
}
