import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/day_plan_model.dart';

/// Обёртка с постоянными вкладками. Текущий индекс знает router
/// ([StatefulNavigationShell]), поэтому виджет — StatelessWidget:
/// StatefulWidget-«леса» из ЛР2 больше не нужны.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // содержимое текущей вкладки
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch, // переключает вкладку
        destinations: const [
          NavigationDestination(
            icon: _PlanBadge(child: Icon(Icons.wb_sunny_outlined)),
            selectedIcon: _PlanBadge(child: Icon(Icons.wb_sunny)),
            label: 'Мой день',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Библия',
          ),
          NavigationDestination(
            // Перо — символ записей в дневнике.
            icon: Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(Icons.history_edu),
            label: 'Дневник',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Вместе',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

/// Бейдж «сколько пунктов плана осталось». Один «живой угол» — Consumer:
/// при изменении плана перерисовывается только бейдж, а не вся панель.
class _PlanBadge extends StatelessWidget {
  final Widget child;

  const _PlanBadge({required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<DayPlanModel>(
      builder: (context, plan, child) => Badge(
        isLabelVisible: plan.remaining > 0,
        label: Text('${plan.remaining}'),
        child: child,
      ),
      child: child,
    );
  }
}
