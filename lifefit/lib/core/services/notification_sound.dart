import 'package:audioplayers/audioplayers.dart';

class NotificationSound {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> play() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/notify.wav'));
    } catch (_) {}
  }
}
