/// Gates local/fast loads so loading UI stays visible at least 2 seconds.
Future<T> withLocalMinDelay<T>(Future<T> future) async {
  late T value;
  await Future.wait<void>([
    future.then((v) {
      value = v;
    }),
    Future<void>.delayed(const Duration(seconds: 2)),
  ]);
  return value;
}
