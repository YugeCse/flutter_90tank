import 'dart:ui' show Rect;

import 'package:flame/game.dart';
import 'package:flutter_90tank/data/land_mass_type.dart';

/// 障碍物信息
///
/// 每个障碍物由一个矩形区域表示
class ObstacleInfo {
  /// 障碍物在地图中的位置
  final int tileX;

  /// 障碍物在地图中的位置
  final int tileY;

  /// 障碍物的大小
  final Vector2 size;

  /// 障碍物的类型
  final LandMassType type;

  /// 构造方法
  ObstacleInfo(this.tileX, this.tileY, this.size, this.type);

  /// 获取障碍物的矩形区域
  Rect get rect => position.toPositionedRect(size);

  /// 判断障碍物是否与另一个矩形区域重叠
  bool isOverlaps(Rect other) => rect.overlaps(other);

  /// 获取障碍物在地图中的位置
  Vector2 get position => Vector2(tileX * size.x, tileY * size.y);
}
