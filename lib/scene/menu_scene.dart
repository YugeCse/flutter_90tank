import 'dart:async';
import 'dart:ui' show Image;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' show Canvas, KeyEvent, KeyEventResult;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_90tank/data/constants.dart';
import 'package:flutter_90tank/tank_game.dart' show TankGame;

/// This is the menu scene
class MenuScene extends PositionComponent
    with TapCallbacks, HasGameRef<TankGame> {
  MenuScene({super.size, super.position});

  /// 玩家数量
  int playerCount = 1;

  /// 菜单场景图片
  late Image menuImage;

  /// 选择坦克玩家的图片
  SpriteComponent? selectTank;

  /// 是否允许按键事件
  bool _allowKeyEvent = false;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    debugMode = true;
    menuImage = await Flame.images.load(Constants.menuImagePath);
    add(
      SpriteComponent.fromImage(
        menuImage,
        size: size,
        position: Vector2(0, size.y),
      )..add(
        MoveEffect.to(Vector2(0, 0), LinearEffectController(2))
          ..onComplete = _addSelectTankToScene,
      ),
    );
  }

  /// 添加选择玩家的坦克图片
  void _addSelectTankToScene() {
    add(
      selectTank =
          SpriteComponent.fromImage(
              gameRef.resImage,
              size: Vector2.all(27),
              srcSize: Vector2.all(27),
              srcPosition: Constants.selectTankImagePosition,
              position: Vector2(Constants.selectTankImagePosition.x, 250),
            )
            ..opacity = 0.0
            ..add(
              OpacityEffect.to(1.0, LinearEffectController(1))
                ..onComplete = () => _allowKeyEvent = true,
            ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    event.handled = true;
    super.onTapDown(event);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.clipRect(size.toRect());
  }

  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!_allowKeyEvent) {
      return KeyEventResult.ignored;
    }
    if (keysPressed.intersection({
      LogicalKeyboardKey.keyW,
      LogicalKeyboardKey.arrowUp,
    }).isNotEmpty) {
      playerCount = 1;
      selectTank?.position.y = 250;
      return KeyEventResult.handled;
    }
    if (keysPressed.intersection({
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.arrowDown,
    }).isNotEmpty) {
      playerCount = 2;
      selectTank?.position.y = 281;
      return KeyEventResult.handled;
    }
    if (keysPressed.intersection({
      LogicalKeyboardKey.enter,
      LogicalKeyboardKey.space,
    }).isNotEmpty) {
      gameRef.onPrepareGame();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
