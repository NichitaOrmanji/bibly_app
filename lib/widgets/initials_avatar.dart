import 'package:flutter/material.dart';

/// Круглый аватар с инициалами вместо фотографии.
/// Используется в «Профиле» и в ленте и группах «Вместе».
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const InitialsAvatar({super.key, required this.name, this.radius = 20});

  /// «Никита Орманжи» → «НО», «Андрей» → «А».
  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initialsOf(name),
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w600,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
