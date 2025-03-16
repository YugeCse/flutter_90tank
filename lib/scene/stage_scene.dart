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

  void Function()? onStartGame;

  void Function()? onStartGameFinished;

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
        size: Vector2(size.x, size.y / 2),
        paint: Paint()..color = Colors.grey,
      ),
    );
    add(
      _rightRectangleComponent = RectangleComponent(
        size: Vector2(size.x, size.y / 2),
        position: Vector2(0, size.y / 2),
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
    onStartGame?.call();
    _leftRectangleComponent.add(
      MoveEffect.to(Vector2(0, -size.y / 2), LinearEffectController(3)),
    );
    _rightRectangleComponent.add(
      MoveEffect.to(Vector2(0, size.y), LinearEffectController(3))
        ..onComplete = onStartGameFinished,
    );
  }

  KeyEventResult handleKeyEvent(
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
