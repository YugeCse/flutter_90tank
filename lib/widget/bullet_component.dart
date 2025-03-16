import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_90tank/data/constants.dart';
import 'package:flutter_90tank/data/land_mass_type.dart' show LandMassType;
import 'package:flutter_90tank/data/move_direction.dart';
import 'package:flutter_90tank/data/obstacle_info.dart' show ObstacleInfo;
import 'package:flutter_90tank/data/role_type.dart';
import 'package:flutter_90tank/tank_game.dart';
import 'package:flutter_90tank/utils/sound_effect.dart';
import 'package:flutter_90tank/widget/map_component.dart';
import 'package:flutter_90tank/widget/role_detector_mixin.dart'
    show RoleDetectorMixin;
import 'package:flutter_90tank/widget/tank_component.dart';

/// 子弹组件
class BulletComponent extends SpriteComponent
    with HasGameRef<TankGame>, RoleDetectorMixin {
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
  static final Vector2 bulletSize = Vector2(6, 16);

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
  void update(double dt) {
    super.update(dt);
    if (!_isDead) {
      position += direction * speed * dt;
    }
    if (parent is MapComponent && !_isDead) {
      var mapComponent = parent as MapComponent;
      var bulletRect = position.toPositionedRect(size);
      if (mapComponent.isCollideWithLimitWall(bulletRect) ||
          _isCollideWithAnyObstacle(mapComponent, bulletRect)) {
        debugPrint('子弹碰到边界墙或障碍物时，发生爆炸 $ownerType');
        _bulletBomb(); // 子弹碰到边界墙或障碍物时，发生爆炸
        return;
      }
      if (_checkBulletHitBullet(mapComponent, bulletRect) ||
          _checkBulletHitTank(mapComponent, bulletRect)) {
        debugPrint('子弹碰到子弹或者碰到其他坦克时，发生爆炸 $ownerType');
        return;
      }
      position += direction * speed * dt; // 子弹继续移动
    }
  }

  /// 判断矩形是否与任何障碍物重叠
  /// - [roleDetector] 角色
  bool _isCollideWithAnyObstacle(MapComponent mapComponent, Rect bulletRect) {
    ObstacleInfo? collideObj;
    var isCollide = mapComponent.obstacles
        .where(
          (el) =>
              ![
                LandMassType.river,
                LandMassType.ice,
                LandMassType.grass,
              ].contains(el.type),
        )
        .any((el) {
          var collide = el.isOverlaps(bulletRect);
          if (collide) collideObj = el; //获取被碰撞的障碍物
          return collide && collideObj != null;
        });
    if (collideObj?.type != LandMassType.grid) {
      mapComponent.obstacles.remove(collideObj); //移除障碍物
      debugPrint('子弹与障碍物碰撞----->${collideObj?.type}');
    }
    return isCollide;
  }

  /// 检测子弹碰到子弹
  bool _checkBulletHitBullet(MapComponent mapComponent, Rect bulletRect) {
    var bullets = mapComponent.children.whereType<BulletComponent>();
    var collideBullets = bullets.where(
      (bullet) =>
          bullet.position.toPositionedRect(bullet.size).overlaps(bulletRect),
    );
    if (collideBullets.isEmpty) return false;
    for (var bullet in collideBullets) {
      if (bullet.ownerType != ownerType) {
        _bulletBomb(); // 子弹爆炸
        bullet._bulletBomb(); // 子弹碰到敌人子弹
        return true;
      }
    }
    return false;
  }

  /// 检查子弹是否碰到坦克
  bool _checkBulletHitTank(MapComponent mapComponent, Rect bulletRect) {
    var result = mapComponent.isCollideWithAnyTank(
      rect: bulletRect,
      rectOfRole:
          ownerType == typeOfEnemy ? RoleType.enemyBullet : RoleType.heroBullet,
    );
    if (!result.$1) return false;
    for (var tank in result.$2) {
      if (tank is TankComponent) {
        tank.hurt(); // 子弹碰到敌人坦克
      }
      _bulletBomb(); //子弹爆炸
      return true;
    }
    debugPrint('-----> 子弹与敌机发生碰撞');
    return false;
  }

  /// 子弹爆炸并等待一段时间消失
  void _bulletBomb() {
    _isDead = true; //标识子弹已经完成使命
    var newSize = MapComponent.warTileSize * 2;
    if (direction == MoveDirection.up || direction == MoveDirection.down) {
      position.x -= (newSize.x / 2 - size.x / 2);
    } else {
      position.y -= (newSize.y / 2 - size.y / 2);
    }
    size = newSize; //更新子弹大小
    sprite = Sprite(
      gameRef.resImage,
      srcSize: newSize,
      srcPosition: Constants.bulletBombImagePosition,
    );
    SoundEffect.playBulletDestoryAudio(); //播放子弹爆炸音效
    add(
      OpacityEffect.to(0, CurvedEffectController(0.26, Curves.easeIn))
        ..onComplete = removeFromParent,
    );
  }
}
