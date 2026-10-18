/// «Сеть» временных хранилищ: задержка и переключаемая авария,
/// общие для всех mock-репозиториев. Леса демонстрации — исчезают на L5
/// вместе с mock-ами.
class MockNetwork {
  /// Авария: включена → любой вызов любого mock-хранилища проваливается.
  bool simulateError = false;

  static const latency = Duration(milliseconds: 800);
  static const errNetwork = 'Сервер не отвечает — повторите попытку';

  /// Пролог каждого метода mock-а: ждём, как настоящая сеть,
  /// и сообщаем, удалась ли «доставка». Без задержки состояние
  /// «грузится» не существует — его нельзя ни увидеть, ни показать.
  Future<bool> roundTrip() async {
    await Future.delayed(latency);
    return !simulateError;
  }
}
