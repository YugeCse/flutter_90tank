import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_90tank/data/constants.dart';
import 'package:flutter_90tank/data/land_mass_type.dart' show LandMassType;
import 'package:flutter_90tank/data/move_direction.dart';
import 'package:flutter_90tank/data/obstacle_info.dart' show ObstacleInfo;
import 'package:flutter_90tank/data/role_type.dart';
import 'package:flutter_90tank/scene/tank_war_scene.dart';
import 'package:flutter_90tank/tank_game.dart';
import 'package:flutter_90tank/utils/sound_effect.dart';
import 'package:flutter_90tank/widget/map_component.dart';
import 'package:flutter_90tank/widget/map_tiled_component.dart';
import 'package:flutter_90tank/widget/role_detector_mixin.dart'
    show RoleDetectorMixin;
import 'package:flutter_90tank/widget/tank_component.dart';

/// 子弹组件
class BulletComponent extends SpriteComponent
    with HasGameRef<TankGame>, RoleDetectorMixin, CollisionCallbacks {
  BulletComponent({
    super.position,
    required this.direction,
    this.speed = 130,
    required this.owner,
    required this.ownerType,
  }) : super(size: bulletSize);

  static const int typeOfEnemy = 0;

  static const int typeOfPlayer = 1;

  /// 子弹的尺寸大小
  static final Vector2 bulletSize = Vector2(6, 6);

  /// 子弹的拥有者
  final Component owner;

  /// 子弹的拥有者类型
  final int ownerType;

  /// 子弹的移动速度
  final double speed;

  /// 子弹方向
  final Vector2 direction;

  /// 子弹是否被销毁
  bool _isDead = false;

  /// 子弹的碰撞盒子
  late RectangleHitbox hitBox;

  @override
  RoleType get roleType =>
      ownerType == typeOfEnemy ? RoleType.enemyBullet : RoleType.heroBullet;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    sprite = Sprite(
      gameRef.resImage,
      srcSize: bulletSize,
      srcPosition: _bulletImagePosition,
    );
    add(hitBox = RectangleHitbox()..debugMode = false);
  }

  /// 获取子弹的图片位置
  Vector2 get _bulletImagePosition {
    var targetPosition = Constants.bulletImagePosition.clone();
    if (direction == MoveDirection.up) {
      return targetPosition;
    } else if (direction == MoveDirection.down) {
      return targetPosition..x += bulletSize.x * 1;
    } else if (direction == MoveDirection.left) {
      return targetPosition..x += bulletSize.x * 2;
    } else {
      return targetPosition..x += bulletSize.x * 3;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is TankComponent) {
      if ((ownerType == typeOfEnemy && other is HeroTankComponent) ||
          (ownerType == typeOfPlayer && other is EnemyTankComponent)) {
        other.hurt();
        _bulletBomb(); // 子弹发生爆炸
      }
    } else if (other is MapTiledComponent) {
      _bulletBomb(); // 子弹发生爆炸
      other.hurt(); // 地图砖块发生爆炸
      if (other.landMassType == LandMassType.wall) {}
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    var mapComponent = parent as MapComponent;
    var tmpPosition = position.clone();
    Rect bulletRect;
    if (!_isDead) {
      tmpPosition += direction * speed * dt;
      bulletRect = tmpPosition.toPositionedRect(size);
      if (mapComponent.isCollideWithLimitWall(bulletRect)) {
        _bulletBomb(); // 子弹碰到边界墙或障碍物时，发生爆炸
        return;
      }
      position = tmpPosition; //更新子弹的最新位置
    }
  }

  /// 子弹爆炸并等待一段时间消失
  void _bulletBomb() {
    _isDead = true; //标识子弹已经完成使命, 否则它还会继续移动
    hitBox.collisionType = CollisionType.inactive; //子弹不再检测碰撞
    sprite = Sprite(
      gameRef.resImage,
      srcSize: size,
      srcPosition: Constants.bulletBombImagePosition,
    );
    anchor = Anchor.center; //设置锚点为中心
    size = MapComponent.warTileSize * 2; //更新子弹大小
    add(
      OpacityEffect.to(0, CurvedEffectController(0.26, Curves.easeIn))
        ..onComplete = removeFromParent,
    );
    SoundEffect.playBulletDestoryAudio(); //播放子弹爆炸音效
  }
}
