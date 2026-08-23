enum NavInput { up, down, left, right, select, back }

abstract class InputSource {
  Stream<NavInput> get events;
  Future<void> dispose();
}