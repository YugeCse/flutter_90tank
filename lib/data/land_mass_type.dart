import 'package:flutter_90tank/widget/role_detector_mixin.dart';

/// 地图地块类
enum LandMassType {
  /// 泥墙
  wall(1, 0),

  /// 钢墙
  grid(2, 1),

  /// 草地
  grass(3, 2),

  /// 河流
  river(4, 3),

  /// 冰块
  ice(5, 4);

  // /// 玩家总部
  // home(9, -1),

  // /// 另一个玩家总部
  // anotherHome(10, -1);

  final int value;

  final int imageIndex;

  const LandMassType(this.value, this.imageIndex);

  static LandMassType? fromValue(int value) {
    try {
      return values.firstWhere((element) => element.value == value);
    } catch (e) {
      return null;
    }
  }
}
