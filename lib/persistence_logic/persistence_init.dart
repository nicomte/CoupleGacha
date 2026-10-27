import 'dart:io';

import 'active_challenges.dart';
import 'player_rewards.dart';
import 'players.dart';

/// Call once before runApp():
///
///   void main() async {
///     WidgetsFlutterBinding.ensureInitialized();
///     await initPersistence(Directory('/home/pi/quiz_data')); // any writable dir
///     runApp(const MyApp());
///   }

Future<void> initPersistence(Directory dir) async {
  await dir.create(recursive: true);
  await Future.wait([
    playerStore.load(dir),
    playerRewards.load(dir),
    activeChallenges.load(dir),
  ]);
}
