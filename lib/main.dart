import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_90tank/tank_game.dart';

void main() {
  runApp(GameWidget.controlled(gameFactory: () => TankGame()));
}
