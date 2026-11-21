import 'dart:async';
import 'package:couple_gacha/navigation/input_source.dart';

class CompositeInputSource implements InputSource {
  CompositeInputSource(this._sources) {
    _controller = StreamController<NavInput>.broadcast(
      onListen: () {
        _subs = _sources.map((s) => s.events.listen(_controller.add)).toList();
      },
      onCancel: () {
        for (final sub in _subs) {
          sub.cancel();
        }
        _subs = [];
      },
    );
  }

  final List<InputSource> _sources;
  late final StreamController<NavInput> _controller;
  List<StreamSubscription<NavInput>> _subs = [];

  @override
  Stream<NavInput> get events => _controller.stream;

  @override
  Future<void> dispose() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    for (final s in _sources) {
      await s.dispose();
    }
    await _controller.close();
  }
}