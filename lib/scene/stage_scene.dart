import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_90tank/tank_game.dart' show TankGame;

class StageScene extends PositionComponent with HasGameRef<TankGame> {
  StageScene({super.size, super.position});

  TimerComponent? _stageTimerComponent;

  late TextComponent _stageTextComponent;

  late RectangleComponent _leftRectangleComponent;

  late RectangleComponent _rightRectangleComponent;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    add(
      _stageTimerComponent = TimerComponent(
        period: 6,
        onTick: _onEnterPlayScene,
      ),
    );
    add(
      _leftRectangleComponent = RectangleComponent(
        size: Vector2(size.x / 2, size.y),
        paint: Paint()..color = Colors.grey,
      ),
    );
    add(
      _rightRectangleComponent = RectangleComponent(
        size: Vector2(size.x / 2, size.y),
        position: Vector2(size.x / 2, 0),
        paint: Paint()..color = Colors.grey,
      ),
    );
    add(
      _stageTextComponent = TextComponent(
        text: 'STAGE ${gameRef.currentStage + 1}',
        textRenderer: TextPaint(style: TextStyle(fontSize: 50)),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _stageTextComponent.position = Vector2(
      size.x / 2 - _stageTextComponent.size.x / 2,
      size.y / 2 - _stageTextComponent.size.y / 2,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.clipRect(size.toRect());
  }

  /// 进入游戏场景
  void _onEnterPlayScene() {
    if (_stageTimerComponent != null) {
      _stageTimerComponent?.removeFromParent();
      _stageTimerComponent = null;
    }
    debugPrint('enter play scene');
    // _stageTextComponent.add(
    //   ColorEffect(Colors.white, LinearEffectController(3)),
    // );
    _leftRectangleComponent.add(
      MoveEffect.to(Vector2(-size.x / 2.0, 0), LinearEffectController(3)),
    );
    _rightRectangleComponent.add(
      MoveEffect.to(Vector2(size.x, 0), LinearEffectController(3))
        ..onComplete = gameRef.onStartGame,
    );
  }

  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (_stageTimerComponent == null) {
      return KeyEventResult.ignored;
    }
    if (keysPressed.intersection({
      LogicalKeyboardKey.space,
      LogicalKeyboardKey.enter,
    }).isNotEmpty) {
      _onEnterPlayScene(); // 空格键
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
