import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Reads/writes one JSON file with power-loss protection:
///   1. data is written to "<name>.tmp" and flushed (fsync) to disk
///   2. the tmp file is renamed over the real file (atomic on Linux)
/// So the real file is always either the old or the new complete version.
///
/// Writes are coalesced: if several changes happen while a write is still
/// running, only the newest state is written afterwards. This spares the SD card
/// and the Pi's CPU. Nothing is delayed with timers, so nothing is lost on exit
/// except what happened in the last few milliseconds.
class JsonFile {
  final File _file;
  final File _tmp;

  String? _pending; // newest serialized state not yet written
  Future<void>? _inFlight; // running write loop, if any

  JsonFile(String path)
      : _file = File(path),
        _tmp = File('$path.tmp');

  /// Returns the decoded JSON, or null if the file is missing or unreadable.
  Future<Object?> read() async {
    // A leftover tmp means we crashed mid-write; the real file is still intact.
    if (await _tmp.exists()) await _tmp.delete();
    if (!await _file.exists()) return null;
    try {
      return jsonDecode(await _file.readAsString());
    } catch (e) {
      debugPrint('Corrupt JSON in ${_file.path}: $e');
      // Keep the broken file for inspection instead of overwriting it.
      await _file.rename('${_file.path}.corrupt');
      return null;
    }
  }

  /// Serializes [data] immediately (so later changes can't sneak in half-way)
  /// and writes it. The returned future completes when it is on disk.
  Future<void> write(Object? data) {
    _pending = jsonEncode(data);
    return _inFlight ??= _drain();
  }

  Future<void> _drain() async {
    try {
      while (_pending != null) {
        final json = _pending!;
        _pending = null;
        await _tmp.writeAsString(json, flush: true);
        await _tmp.rename(_file.path);
      }
    } finally {
      _inFlight = null;
    }
  }
}

/// Base class for everything that is persisted.
/// Subclasses implement [fileName], [toJson], [fromJson] and call [changed]
/// after every mutation.
abstract class PersistentStore extends ChangeNotifier {
  JsonFile? _json;

  String get fileName;

  /// Must return something jsonEncode can handle (Map<String, ...> / List).
  Object toJson();

  /// Replace the current content with the decoded [json].
  void fromJson(Object json);

  /// Call once at startup (see initPersistence).
  Future<void> load(Directory dir) async {
    _json = JsonFile('${dir.path}/$fileName');
    final data = await _json!.read();
    if (data != null) {
      try {
        fromJson(data);
      } catch (e) {
        debugPrint('Could not parse $fileName: $e');
      }
    }
    notifyListeners();
  }

  /// Call after every change: updates the UI and persists to disk.
  @protected
  void changed() {
    notifyListeners();
    final json = _json;
    if (json == null) return; // not loaded yet (e.g. in tests)
    json.write(toJson()).catchError((Object e) {
      debugPrint('Saving $fileName failed: $e');
    });
  }
}
