import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_90tank/tank_game.dart' show TankGame;
import 'package:flutter_90tank/utils/sound_effect.dart';
import 'package:flutter_90tank/widget/map_component.dart';

/// 坦克大战场景
class TankWarScene extends PositionComponent with HasGameRef<TankGame> {
  ///构造函数
  TankWarScene({this.stage = 0, super.position, super.size});

  /// 游戏关卡
  final int stage;

  /// 游戏地图组件
  late MapComponent mapComponent;

  /// 战场的偏移量
  static final Vector2 warGroundOffset = Vector2(32, 16);

  /// 战场的大小
  static final Vector2 warGroundSize = Vector2(416, 416);

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    add(
      mapComponent = MapComponent(
        stage: stage,
        size: warGroundSize,
        position: warGroundOffset,
      ),
    );
    SoundEffect.playStartGameAudio(); //播放开始游戏音频
  }

  @override
  void render(Canvas canvas) {
    var paint = Paint()..color = Color(0xff7f7f7f);
    canvas.drawRect(size.toRect(), paint);
    super.render(canvas);
  }

  /// 处理玩家按键事件
  KeyEventResult handleKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) => mapComponent.handleKeyEvent(event, keysPressed);
}
