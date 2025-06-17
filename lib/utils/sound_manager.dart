import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final _player = AudioPlayer();

  static Future<void> playFlip() async {
    await _player.play(AssetSource('sounds/flip.mp3'));
  }

  static Future<void> playMatch() async {
    await _player.play(AssetSource('sounds/match.mp3'));
  }

  static Future<void> playWin() async {
    await _player.play(AssetSource('sounds/win.mp3'));
  }
}
