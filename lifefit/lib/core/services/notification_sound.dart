import 'package:audioplayers/audioplayers.dart';

/// Plays the bundled notification sound (`assets/sounds/notify.wav`).
class NotificationSound {
  static final AudioPlayer _player = AudioPlayer();

  /// Stops any in-progress sound, then plays the notify asset.
  static Future<void> play() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/notify.wav'));
    } catch (_) {}
  }
}
