import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_90tank/data/constants.dart';
import 'package:flutter_90tank/data/land_mass_type.dart';
import 'package:flutter_90tank/tank_game.dart' show TankGame;
import 'package:flutter_90tank/widget/map_component.dart';

/// 地图瓦片组件
class MapTiledComponent extends SpriteComponent with HasGameRef<TankGame> {
  MapTiledComponent({super.size, super.position, required this.landMassType});

  /// 碰撞盒子组件
  RectangleHitbox? hitbox;

  /// 地砖材质
  final LandMassType landMassType;

  /// 子弹是否可通行
  bool get isBulletCanPassable =>
      landMassType == LandMassType.grass ||
      landMassType == LandMassType.ice ||
      landMassType == LandMassType.river;

  /// 坦克是否可通行
  bool get isTankCanPassable =>
      landMassType == LandMassType.grass || landMassType == LandMassType.ice;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    sprite = Sprite(
      gameRef.resImage,
      srcPosition:
          Constants.mapLandMassImagePosition.clone()
            ..x += landMassType.imageIndex * MapComponent.warTileSize.x,
      srcSize: MapComponent.warTileSize,
    );
    size = MapComponent.warTileSize;
    priority = landMassType.layerLevel;
    if (landMassType == LandMassType.grass ||
        landMassType == LandMassType.ice ||
        landMassType == LandMassType.river) {
      return;
    }
    add(hitbox = RectangleHitbox(size: size, isSolid: true)..debugMode = false);
  }

  /// 受到伤害
  void hurt() {
    if (landMassType == LandMassType.grid) return; //钢筋墙不可破坏
    hitbox?.collisionType = CollisionType.inactive;
    removeFromParent(); //从父组件中移除
  }
}
