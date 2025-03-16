import 'dart:math';

import 'package:flame/extensions.dart';

class MoveDirection {
  MoveDirection._();

  static final idle = Vector2.zero();

  static final up = Vector2(0, -1);

  static final down = Vector2(0, 1);

  static final left = Vector2(-1, 0);

  static final right = Vector2(1, 0);

  static final List<Vector2> values = [idle, up, down, left, right];

  static Vector2 random() => values[Random().nextInt(values.length)];
}
