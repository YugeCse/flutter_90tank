import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

/// This class is used to play sound effects
class SoundEffect {
  SoundEffect._();

  /// Play a sound effect
  static FutureOr<AudioPlayer?> playSound({required String name}) {
    return null;
    // return FlameAudio.play(name);
  }

  static void playStartGameAudio() => playSound(name: 'start.mp3');

  static void playBulletDestoryAudio() => playSound(name: 'bulletCrack.mp3');

  static void playTankDestoryAudio() => playSound(name: 'tankCrack.mp3');

  static void playMoveAudio() => playSound(name: 'move.mp3');

  static void playAttackAudio() => playSound(name: 'attack.mp3');

  static void playPropAudio() => playSound(name: 'prop.mp3');
}
