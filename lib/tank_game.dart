import 'dart:async';
import 'dart:ui' show Image;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show Canvas, KeyEvent, KeyEventResult;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_90tank/data/constants.dart';
import 'package:flutter_90tank/data/game_state.dart';
import 'package:flutter_90tank/scene/menu_scene.dart';
import 'package:flutter_90tank/scene/stage_scene.dart';
import 'package:flutter_90tank/scene/tank_war_scene.dart';

class TankGame extends FlameGame with KeyboardEvents {
  /// 游戏状态
  GameState state = GameState.start;

  /// 当前关卡
  int currentStage = 0;

  /// 游戏资源图片
  late Image resImage;

  /// 游戏菜单场景
  MenuScene? _menuScene;

  /// 游戏关卡场景
  StageScene? _stageScene;

  /// 游戏坦克战斗场景
  TankWarScene? _tankWarScene;

  late TextComponent sizeTextComponent;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    resImage = await images.load(Constants.resourceImagePath);
    add(
      _tankWarScene = TankWarScene(
        stage: 21,
        position:
            TankWarScene.warGroundOffset +
            Vector2(0, size.y / 2.0 - TankWarScene.warGroundSize.y / 2.0),
        size: TankWarScene.warGroundSize + TankWarScene.warGroundOffset * 2,
      ),
    );
    // add(
    //   _menuScene = MenuScene(
    //     position: size / 2.0 - Constants.screenSize / 2.0,
    //     size: Vector2(Constants.screenWidth, Constants.screenHeight),
    //   ),
    // ); // 添加菜单场景
    add(sizeTextComponent = TextComponent());
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _menuScene?.position = size / 2.0 - Constants.screenSize / 2.0;
    _tankWarScene?.position = size / 2.0 - Constants.screenSize / 2.0;
  }

  /// 显示菜单
  void onShowMenu() {
    state = GameState.menu;
    if (_menuScene != null) {
      _menuScene?.removeFromParent();
      _menuScene = null;
    }
    add(
      _menuScene = MenuScene(
        position: size / 2.0 - Constants.screenSize / 2.0,
        size: Vector2(Constants.screenWidth, Constants.screenHeight),
      ),
    );
  }

  /// 准备游戏 - 关卡准备
  void onPrepareGame() {
    state = GameState.init;
    _menuScene?.removeFromParent();
    _menuScene = null;
    if (_stageScene != null) {
      _stageScene?.removeFromParent();
      _stageScene = null;
    }
    add(
      _stageScene = StageScene(
        size: Constants.screenSize,
        position: size / 2.0 - Constants.screenSize / 2.0,
      ),
    );
  }

  /// 开始游戏
  void onStartGame() {
    state = GameState.start;
    if (_stageScene != null) {
      _stageScene?.removeFromParent();
      _stageScene = null;
    }
    if (_tankWarScene != null) {
      _tankWarScene?.removeFromParent();
      _tankWarScene = null;
    }
    add(
      _tankWarScene = TankWarScene(
        size: Constants.screenSize,
        position: size / 2.0 - Constants.screenSize / 2.0,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sizeTextComponent.text = 'size: ${size.x.toInt()}, ${size.y.toInt()}';
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (state == GameState.menu) {
      return _menuScene?.onKeyEvent(event, keysPressed) ??
          super.onKeyEvent(event, keysPressed);
    } else if (state == GameState.init) {
      return _stageScene?.onKeyEvent(event, keysPressed) ??
          super.onKeyEvent(event, keysPressed);
    } else if (state == GameState.start) {
      debugPrint('keysPressed: $keysPressed');
      return _tankWarScene?.handleKeyEvent(event, keysPressed) ??
          super.onKeyEvent(event, keysPressed);
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
