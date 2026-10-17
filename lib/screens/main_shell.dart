import 'package:flutter/material.dart';

import '../widgets/coming_soon_view.dart';
import 'my_day_screen.dart';

/// Оболочка с нижней навигацией. Единственное состояние — индекс
/// выбранной вкладки (это допускается условиями ЛР2).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _pages = [
    MyDayScreen(),
    ComingSoonView(title: 'Библия', icon: Icons.menu_book_outlined),
    ComingSoonView(title: 'Вместе', icon: Icons.groups_outlined),
    ComingSoonView(title: 'Скиния', icon: Icons.church_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack сохраняет прокрутку вкладок при переключении.
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Мой день',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Библия',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Вместе',
          ),
          NavigationDestination(
            icon: Icon(Icons.church_outlined),
            selectedIcon: Icon(Icons.church),
            label: 'Скиния',
          ),
        ],
      ),
    );
  }
}
