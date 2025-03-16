import 'dart:async';
import 'dart:ui' show Image;

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show KeyEvent, KeyEventResult;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_90tank/data/constants.dart';
import 'package:flutter_90tank/data/game_state.dart';
import 'package:flutter_90tank/event/base_event.dart';
import 'package:flutter_90tank/scene/menu_scene.dart';
import 'package:flutter_90tank/scene/tank_war_scene.dart';
import 'package:flutter_90tank/widget/map_component.dart';

class TankGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  /// 游戏状态
  GameState state = GameState.menu;

  /// 当前关卡
  int currentStage = 0;

  /// 游戏资源图片
  late Image resImage;

  /// 游戏菜单场景
  MenuScene? _menuScene;

  /// 游戏坦克战斗场景
  TankWarScene? tankWarScene;

  /// 事件消息控制对象
  final StreamController<BaseEvent> eventMsgController =
      StreamController<BaseEvent>.broadcast();

  /// 发送消息事件
  void sendMsgEvent<T extends BaseEvent>(T event) =>
      eventMsgController.sink.add(event);

  /// 订阅消息事件
  StreamSubscription<BaseEvent> subscribeMsgEvent<T extends BaseEvent>(
    void Function(T event) callback,
  ) {
    return eventMsgController.stream.listen((event) {
      if (event is T) callback(event);
    });
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    resImage = await images.load(Constants.resourceImagePath);
    // add(
    //   tankWarScene = TankWarScene(
    //     stage: 3,
    //     position:
    //         TankWarScene.warGroundOffset +
    //         Vector2(0, size.y / 2.0 - TankWarScene.warGroundSize.y / 2.0),
    //     size: TankWarScene.warGroundSize + TankWarScene.warGroundOffset * 2,
    //   ),
    // );
    add(
      _menuScene = MenuScene(
        position: size / 2.0 - Constants.screenSize / 2.0,
        size: Vector2(Constants.screenWidth, Constants.screenHeight),
      ),
    ); // 添加菜单场景
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _menuScene?.position = size / 2.0 - Constants.screenSize / 2.0;
    tankWarScene?.position = size / 2.0 - Constants.screenSize / 2.0;
  }

  /// 开始游戏
  void onStartGame() {
    state = GameState.init;
    if (tankWarScene != null) {
      tankWarScene?.removeFromParent();
      tankWarScene = null;
    }
    debugPrint('开始游戏');
    var tankWarSceneSize =
        TankWarScene.warGroundSize +
        TankWarScene.warGroundOffset * 2 +
        MapComponent.warTileSize * 2;
    add(
      tankWarScene = TankWarScene(
        stage: 3,
        size: tankWarSceneSize,
        position: Vector2(
          size.x / 2.0 - tankWarSceneSize.x / 2.0,
          size.y / 2.0 - tankWarSceneSize.y / 2.0,
        ),
      ),
    );
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (state == GameState.menu) {
      return _menuScene?.handleKeyEvent(event, keysPressed) ??
          super.onKeyEvent(event, keysPressed);
    } else if (state == GameState.init ||
        state == GameState.start ||
        state == GameState.over ||
        state == GameState.win) {
      debugPrint('keysPressed: $keysPressed');
      return tankWarScene?.handleKeyEvent(event, keysPressed) ??
          super.onKeyEvent(event, keysPressed);
    }
    return super.onKeyEvent(event, keysPressed);
  }
}
