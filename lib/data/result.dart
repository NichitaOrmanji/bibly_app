/// Вердикт операции хранилища: данные или сообщение для экрана (C8).
/// Ожидаемый отказ — значение, а не исключение, летящее через UI.
/// switch по sealed-типу исчерпывающий: компилятор не даст забыть Err.
sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.msg);
  final String msg;
}
