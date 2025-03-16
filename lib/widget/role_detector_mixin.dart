import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Rect;
import 'package:flutter_90tank/data/role_type.dart' show RoleType;

/// 角色检测器
mixin RoleDetectorMixin on PositionComponent {
  /// 角色类型
  RoleType get roleType;

  /// 获取碰撞矩形
  Rect get hitBoxRect => position.toPositionedRect(size);
}
