import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show KeyDownEvent, KeyUpEvent, LogicalKeyboardKey;
import 'package:flutter_90tank/data/constants.dart';
import 'package:flutter_90tank/data/move_direction.dart' show MoveDirection;
import 'package:flutter_90tank/data/role_type.dart';
import 'package:flutter_90tank/data/tank_state.dart';
import 'package:flutter_90tank/event/enemy_tank_destroy_event.dart';
import 'package:flutter_90tank/event/hero_tank_destroy_event.dart'
    show HeroTankDestroyEvent;
import 'package:flutter_90tank/scene/tank_war_scene.dart';
import 'package:flutter_90tank/tank_game.dart' show TankGame;
import 'package:flutter_90tank/utils/sound_effect.dart';
import 'package:flutter_90tank/widget/bullet_component.dart'
    show BulletComponent;
import 'package:flutter_90tank/widget/map_component.dart';
import 'package:flutter_90tank/widget/map_tiled_component.dart';
import 'package:flutter_90tank/widget/role_detector_mixin.dart';

abstract class TankComponent extends SpriteComponent with HasGameRef<TankGame> {
  TankComponent({
    super.position,
    super.size,
    this.state = TankState.normal,
    this.invincible = false,
    this.life = 1,
    this.numOfHitsReceived = 1,
    this.speed = 100,
    Vector2? initialDirection,
  }) : direction = initialDirection ?? MoveDirection.up {
    priority = 1;
    size = MapComponent.warTileSize * 2;
  }

  /// 坦克状态
  TankState state;

  /// 坦克是否无敌
  bool invincible;

  /// 坦克生命值
  int life;

  /// 坦克能承受的打击次数
  int numOfHitsReceived;

  /// 坦克移动速度
  double speed;

  /// 坦克移动方向
  Vector2 direction;

  /// 当前born的标识
  int _currentBornTag = 0;

  /// 当前born的标识改变时间
  int _bornTagChangeTime = 0;

  /// 坦克的碰撞矩形组件
  late RectangleHitbox hitBox;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    add(hitBox = RectangleHitbox(isSolid: true)..debugMode = false); // 坦克碰撞检测
  }

  /// 受伤
  void hurt();

  /// 开火
  /// - [ownerType] 子弹的拥有者类型
  void fire({required int ownerType}) {
    if (parent is! MapComponent || direction == MoveDirection.idle) {
      return;
    }
    var mapComponent = parent as MapComponent;
    var bulletPosition = Vector2.zero();
    var bulletSize = BulletComponent.bulletSize;
    if (direction == MoveDirection.up) {
      bulletPosition = Vector2(
        position.x + size.x / 2 - bulletSize.x / 2,
        position.y,
      );
    } else if (direction == MoveDirection.down) {
      bulletPosition = Vector2(
        position.x + size.x / 2 - bulletSize.x / 2,
        position.y + size.y,
      );
    } else if (direction == MoveDirection.left) {
      bulletPosition = Vector2(
        position.x,
        position.y + size.y / 2 - bulletSize.y / 2,
      );
    } else if (direction == MoveDirection.right) {
      bulletPosition = Vector2(
        position.x + size.x,
        position.y + size.y / 2 - bulletSize.y / 2,
      );
    }
    mapComponent.add(
      BulletComponent(
        owner: this,
        speed: 180,
        direction: direction,
        ownerType: ownerType,
        position: bulletPosition,
      ),
    );
    if (ownerType == BulletComponent.typeOfPlayer) {
      SoundEffect.playAttackAudio();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    var paint = Paint()..isAntiAlias = true;
    if (invincible) {
      _drawProtectClothes(canvas, paint);
    }
  }

  /// 绘制保护衣
  void _drawProtectClothes(Canvas canvas, Paint paint) {
    var srcProtectSize = MapComponent.warTileSize * 2;
    var srcProtectPostion = Constants.protectedImagePosition;
    if (_currentBornTag != 0) {
      srcProtectPostion += Vector2(0, srcProtectSize.y);
    }
    var srcProtectRect = srcProtectPostion.toPositionedRect(srcProtectSize);
    canvas.drawImageRect(
      gameRef.resImage,
      srcProtectRect,
      size.toRect(),
      paint,
    );
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - _bornTagChangeTime >= 160) {
      _bornTagChangeTime = currentTime;
      _currentBornTag = _currentBornTag == 0 ? 1 : 0;
    }
  }

  /// 判断坦克矩形是否与任何障碍物重叠
  /// - [tankRect] 矩形
  /// - [rectOwner] 矩形拥有者
  bool isCollisionWithObstacles({required RectangleHitbox hitbox}) {
    if (parent == null || parent is! MapComponent) return false;
    var mapComponent = parent as MapComponent;
    return mapComponent.children
        .whereType<MapTiledComponent>()
        .where(
          (el) =>
              (el.hitbox?.parent as PositionComponent?)?.toRect().overlaps(
                hitbox.toRect().deflate(0.2),
              ) ??
              false,
        )
        .isNotEmpty;
  }

  /// 判断坦克矩形是否与任何其他坦克重叠
  bool isCollisionWithOtherTanks({required RectangleHitbox hitbox}) {
    if (parent == null || parent is! MapComponent) return false;
    var mapComponent = parent as MapComponent;
    if (this is HeroTankComponent) {
      return mapComponent.children.whereType<EnemyTankComponent>().any(
        (el) =>
            (el.hitBox.parent as PositionComponent?)?.toRect().overlaps(
              hitbox.toRect().deflate(0.2),
            ) ??
            false,
      );
    }
    return mapComponent.children.whereType<HeroTankComponent>().any(
      (el) =>
          (el.hitBox.parent as PositionComponent?)?.toRect().overlaps(
            hitbox.toRect().deflate(0.2),
          ) ??
          false,
    );
  }
}

/// 敌机坦克组件
class EnemyTankComponent extends TankComponent with RoleDetectorMixin {
  /// 创建通用坦克
  /// - [enemyImagePosition] 敌人坦克资源图片位置
  /// - [position] 坦克位置
  /// - [size] 坦克大小
  /// - [life] 坦克生命值
  /// - [speed] 坦克移动速度
  /// - [numOfHitsReceived] 坦克能承受的打击次数
  static EnemyTankComponent create({
    required Vector2 enemyImagePosition,
    Vector2? position,
    Vector2? size,
    int life = 1,
    double speed = 100,
    int numOfHitsReceived = 1,
  }) {
    return EnemyTankComponent(
      enemyImagePosition: enemyImagePosition,
      size: size,
      position: position,
      life: life,
      speed: speed,
      numOfHitsReceived: numOfHitsReceived,
    );
  }

  /// 构造函数
  EnemyTankComponent({
    super.position,
    super.size,
    super.life = 1,
    super.invincible = false,
    super.numOfHitsReceived = 1,
    super.speed = 100,
    this.fireLimitTime = 1000,
    this.changeDirectionLimitTime = 800,
    required this.enemyImagePosition,
  }) {
    super.direction = MoveDirection.down;
  }

  /// 敌人坦克资源图片位置
  final Vector2 enemyImagePosition;

  /// 敌人坦克智能改变方向的限制时间
  final int changeDirectionLimitTime;

  /// 敌人坦克智能开火的限制时间
  final int fireLimitTime;

  /// 敌人坦克智能改变方向的判断时间
  int _changeDirectionFrameTime = 0;

  /// 敌人坦克智能开火的判断时间
  int _fireFrameTime = 0;

  @override
  RoleType get roleType => RoleType.enemyTank;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    sprite = Sprite(
      gameRef.resImage,
      srcSize: size,
      srcPosition: enemyImagePosition,
    );
  }

  @override
  void hurt() {
    if (--numOfHitsReceived == 0) {
      hitBox.collisionType = CollisionType.inactive;
      parent?.remove(this); //生命值为1时，移除坦克
      SoundEffect.playTankDestoryAudio(); //播放坦克销毁音效
      gameRef.sendMsgEvent(EnemyTankDestroyEvent());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _autoSmartMove(dt: dt); //敌人智能自动移动
  }

  /// 敌人智能自动移动
  void _autoSmartMove({required double dt}) {
    var curTimeMillis = DateTime.now().millisecondsSinceEpoch;
    if (curTimeMillis - _changeDirectionFrameTime > changeDirectionLimitTime) {
      direction = MoveDirection.random();
      _updateTankDirection(); //更新坦克的资源图片方向
      _changeDirectionFrameTime = curTimeMillis;
    }
    var tmpPosition = position + direction * speed * dt;
    tmpPosition.clamp(Vector2.zero(), TankWarScene.warGroundSize - size);
    var tmpHitBox = RectangleHitbox(
      isSolid: true,
      size: size,
      position: tmpPosition,
    );
    if (isCollisionWithObstacles(hitbox: tmpHitBox) ||
        isCollisionWithOtherTanks(hitbox: tmpHitBox)) {
      return; //发生碰撞时，不更新坦克位置
    }
    position = tmpPosition; //未发生碰撞时，更新坦克位置
    curTimeMillis = DateTime.now().millisecondsSinceEpoch;
    if (Random().nextDouble() > 0.5 &&
        curTimeMillis - _fireFrameTime > fireLimitTime) {
      _fireFrameTime = curTimeMillis;
      fire(ownerType: BulletComponent.typeOfEnemy); //随机开火
    }
  }

  /// 更新坦克的资源图片方向
  void _updateTankDirection() {
    var offsetX = (numOfHitsReceived - 1) * 4 * MapComponent.warTileSize.x;
    if (direction == MoveDirection.up) {
      sprite?.srcPosition = enemyImagePosition;
    } else if (direction == MoveDirection.down) {
      sprite?.srcPosition =
          enemyImagePosition +
          Vector2(MapComponent.warTileSize.x * 2 + offsetX, 0);
    } else if (direction == MoveDirection.left) {
      sprite?.srcPosition =
          enemyImagePosition +
          Vector2(MapComponent.warTileSize.x * 2 * 2 + offsetX, 0);
    } else if (direction == MoveDirection.right) {
      sprite?.srcPosition =
          enemyImagePosition +
          Vector2(MapComponent.warTileSize.x * 2 * 3 + offsetX, 0);
    }
  }
}

class HeroTankComponent extends TankComponent
    with RoleDetectorMixin, CollisionCallbacks {
  HeroTankComponent({
    super.position,
    super.size,
    super.life = 1,
    super.invincible = true,
    super.numOfHitsReceived = 1,
    super.speed = 80,
    super.initialDirection,
    this.fireLimitTime = 300,
  });

  /// 玩家坦克开火的限制时间
  int fireLimitTime;

  int _fireFrameTime = 0;

  /// 玩家当前按下的按键集合
  final Set<LogicalKeyboardKey> _keysPressed = {};

  @override
  RoleType get roleType => RoleType.heroTank;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    sprite = Sprite(
      gameRef.resImage,
      srcSize: size,
      srcPosition: Constants.playerImagePosition,
    );
    // 设置10秒后无敌效果时效
    Future.delayed(Duration(milliseconds: 10000), () => invincible = false);
  }

  @override
  void hurt() {
    if (numOfHitsReceived > 1) {
      numOfHitsReceived--; //坦克被击中，但未死亡
    } else {
      --life; //坦克被击中，生命值减少
      hitBox.collisionType = CollisionType.inactive;
      sprite?.srcPosition = Constants.tankBombImagePosition; //播放爆炸动画
      add(
        OpacityEffect.to(0.0, LinearEffectController(1))
          ..onComplete = () {
            removeFromParent();
            gameRef.sendMsgEvent(HeroTankDestroyEvent());
          },
      );
      SoundEffect.playTankDestoryAudio(); //播放爆炸音效
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateMoveByKeyboard(dt); //更新玩家移动逻辑
  }

  /// 通过键盘更新玩家移动逻辑
  void _updateMoveByKeyboard(double dt) {
    if (_keysPressed.intersection({
      LogicalKeyboardKey.keyW,
      LogicalKeyboardKey.arrowUp,
    }).isNotEmpty) {
      _updateMove(MoveDirection.up, dt);
    } else if (_keysPressed.intersection({
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.arrowDown,
    }).isNotEmpty) {
      _updateMove(MoveDirection.down, dt);
    } else if (_keysPressed.intersection({
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.arrowLeft,
    }).isNotEmpty) {
      _updateMove(MoveDirection.left, dt);
    } else if (_keysPressed.intersection({
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.arrowRight,
    }).isNotEmpty) {
      _updateMove(MoveDirection.right, dt);
    }
  }

  /// 更新坦克移动逻辑
  void _updateMove(Vector2 direction, double dt) {
    this.direction = direction;
    _updateSpriteByDirection(direction);
    var tmpPosition = position.clone() + direction * speed * dt;
    var tmpHitbox = RectangleHitbox(
      size: size,
      isSolid: true,
      position: tmpPosition,
    );
    tmpPosition.clamp(Vector2.zero(), TankWarScene.warGroundSize - size);
    if (isCollisionWithObstacles(hitbox: tmpHitbox) ||
        isCollisionWithOtherTanks(hitbox: tmpHitbox)) {
      return;
    }
    position = tmpPosition; //没有碰撞才能更新坦克位置
  }

  /// 根据坦克方向更新坦克图片
  void _updateSpriteByDirection(Vector2 direction) {
    var imgPosition = Constants.playerImagePosition.clone();
    if (direction == MoveDirection.down) {
      imgPosition.x = MapComponent.warTileSize.x * 2;
    } else if (direction == MoveDirection.left) {
      imgPosition.x = MapComponent.warTileSize.x * 2 * 2;
    } else if (direction == MoveDirection.right) {
      imgPosition.x = MapComponent.warTileSize.x * 2 * 3;
    }
    sprite = Sprite(gameRef.resImage, srcSize: size, srcPosition: imgPosition);
  }

  /// 更新玩家开火逻辑
  void _updateFire() {
    var curTimeMills = DateTime.now().millisecondsSinceEpoch;
    if (curTimeMills - _fireFrameTime <= fireLimitTime) {
      debugPrint('玩家坦克开火间隔时间未到');
      return;
    }
    _fireFrameTime = curTimeMills;
    if (_keysPressed.intersection({
      LogicalKeyboardKey.keyJ,
      LogicalKeyboardKey.keyK,
      LogicalKeyboardKey.space,
    }).isNotEmpty) {
      fire(ownerType: BulletComponent.typeOfPlayer);
    }
  }

  /// 处理玩家按键事件
  KeyEventResult handleKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      _keysPressed.addAll(keysPressed);
      _updateFire(); //更新玩家开火逻辑
      return KeyEventResult.handled;
    }
    if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
