import 'package:flutter/material.dart';

/// Диалог подтверждения деструктивного действия («Выйти», «Удалить»…).
/// Возвращает true, только если пользователь нажал кнопку подтверждения;
/// «Отмена» и закрытие мимо диалога дают false.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    // Закрываем через dialogCtx — контекст самого диалога: под вложенными
    // навигаторами вкладок pop(context) экрана закрыл бы не диалог, а экран.
    builder: (dialogCtx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogCtx).colorScheme.error,
            foregroundColor: Theme.of(dialogCtx).colorScheme.onError,
          ),
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  // Диалог, закрытый нажатием мимо, возвращает null — поэтому == true, а не ok!.
  return ok == true;
}
