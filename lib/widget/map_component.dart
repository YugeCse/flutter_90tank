import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart' show Colors, KeyEvent, KeyEventResult;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_90tank/data/constants.dart';
import 'package:flutter_90tank/data/land_mass_type.dart' show LandMassType;
import 'package:flutter_90tank/data/obstacle_info.dart';
import 'package:flutter_90tank/data/role_type.dart' show RoleType;
import 'package:flutter_90tank/data/stage_level.dart';
import 'package:flutter_90tank/tank_game.dart';
import 'package:flutter_90tank/utils/canvas_utils.dart';
import 'package:flutter_90tank/widget/role_detector_mixin.dart';
import 'package:flutter_90tank/widget/tank_component.dart';

/// 地图组件，负责绘制战场地图
class MapComponent extends PositionComponent with HasGameRef<TankGame> {
  /// 战场图块数量：26x26
  static final int warTileCount = 26;

  /// 战场的图块的大小
  static final Vector2 warTileSize = Vector2.all(16);

  /// 构造方法
  MapComponent({super.size, super.position, this.stage = 0})
    : stageData =
          StageLevel.maps[stage < 0
              ? 0
              : (stage > StageLevel.maps.length - 1
                  ? StageLevel.maps.length - 1
                  : stage)];

  /// 关卡等级
  final int stage;

  /// 关卡地图数据
  final List<List<int>> stageData;

  /// 障碍物信息
  late List<ObstacleInfo> obstacles;

  /// 总部是否还存在
  bool isHomeAlive = false;

  /// 绘制玩家坦克
  HeroTankComponent? _heroTankComponent;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    obstacles = getObstacles(); // 获取障碍物信息
    add(
      _heroTankComponent = HeroTankComponent(
        position: Vector2(
          (warTileCount / 2 - 5) * warTileSize.x,
          size.y - 2 * warTileSize.y,
        ),
      ),
    );
    add(
      EnemyTankComponent.create(
        position: Vector2(0, 0),
        numOfHitsReceived: 1,
        enemyImagePosition: Constants.enemy2ImagePosition,
      ),
    );
    add(
      EnemyTankComponent.create(
        position: Vector2(size.x - warTileSize.x * 2, 0),
        speed: 50,
        numOfHitsReceived: 1,
        enemyImagePosition: Constants.enemy1ImagePosition,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    var paint = Paint()..color = Colors.black;
    canvas.drawRect(size.toRect(), paint);
    super.render(canvas);
    _drawMapTiles(canvas); // 绘制战场地图地块
    _drawHomeTile(canvas, isAlive: true); // 绘制总部地块
  }

  /// 获取障碍物的信息
  List<ObstacleInfo> getObstacles() {
    List<ObstacleInfo> obstacles = [];
    for (var y = 0; y < warTileCount; y++) {
      for (var x = 0; x < warTileCount; x++) {
        var tileData = stageData[y][x];
        var landMassType = LandMassType.fromValue(tileData);
        if (landMassType == null) continue;
        if ([
          LandMassType.wall,
          LandMassType.grid,
          LandMassType.river,
          LandMassType.ice,
        ].contains(landMassType)) {
          obstacles.add(ObstacleInfo(x, y, warTileSize, landMassType));
        }
      }
    }
    return obstacles;
  }

  /// 绘制战场地图地块
  void _drawMapTiles(Canvas canvas) {
    for (var i = 0; i < obstacles.length; i++) {
      var obstacle = obstacles[i];
      canvas.drawMapTile(
        column: obstacle.tileX,
        row: obstacle.tileY,
        tileSize: warTileSize,
        type: obstacle.type,
        resImage: gameRef.resImage,
      );
    }
  }

  /// 绘制总部地块
  /// - [isAlive] 是否存活，默认：true
  void _drawHomeTile(Canvas canvas, {bool isAlive = true}) {
    var dstRect = Rect.fromLTWH(
      warTileCount * warTileSize.x / 2 - warTileSize.x,
      size.y - 2 * warTileSize.y,
      warTileSize.x * 2,
      warTileSize.y * 2,
    );
    var srcRect = (Constants.homeImagePosition +
            (isAlive ? Vector2.zero() : Vector2(2 * warTileSize.x, 0)))
        .toPositionedRect(warTileSize * 2);
    canvas.drawImageRect(gameRef.resImage, srcRect, dstRect, Paint());
  }

  /// 判断矩形是否与边界墙重叠
  bool isCollideWithLimitWall(Rect rect) {
    return rect.left < 0 ||
        rect.right > size.x ||
        rect.top < 0 ||
        rect.bottom > size.y;
  }

  /// 判断矩形是否与其他坦克矩形重叠
  /// - [rect] 矩形
  /// - [role] 矩形来源的角色
  (bool, List<Component>) isCollideWithAnyTank({
    required Rect rect,
    required RoleType rectOfRole,
  }) {
    if ([RoleType.heroTank, RoleType.heroBullet].contains(rectOfRole)) {
      var result = children.whereType<EnemyTankComponent>().where(
        (el) => el.position.toPositionedRect(el.size).overlaps(rect),
      );
      return (result.isNotEmpty, result.toList());
    }
    var result = children.whereType<HeroTankComponent>().where(
      (el) => el.position.toPositionedRect(el.size).overlaps(rect),
    );
    return (result.isNotEmpty, result.toList());
  }

  /// 获取障碍物矩形列表
  List<Rect> get allObstacleRects =>
      obstacles
          .where(
            (e) => e.type != LandMassType.grass || e.type != LandMassType.ice,
          )
          .map((e) => e.rect)
          .toList();

  /// 处理玩家按键事件
  KeyEventResult handleKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (_heroTankComponent != null) {
      return _heroTankComponent?.handleKeyEvent(event, keysPressed) ??
          KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }
}
