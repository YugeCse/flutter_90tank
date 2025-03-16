/// 地图地块类
enum LandMassType {
  /// 泥墙
  wall(1, 0, 0),

  /// 钢墙
  grid(2, 1, 0),

  /// 草地
  grass(3, 2, 1000),

  /// 河流
  river(4, 3, 0),

  /// 冰块
  ice(5, 4, 0);

  // /// 玩家总部
  // home(9, -1),

  // /// 另一个玩家总部
  // anotherHome(10, -1);

  final int value;

  final int imageIndex;

  final int layerLevel;

  const LandMassType(this.value, this.imageIndex, this.layerLevel);

  static LandMassType? fromValue(int value) {
    try {
      return values.firstWhere((element) => element.value == value);
    } catch (e) {
      return null;
    }
  }
}
