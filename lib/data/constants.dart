import 'package:flame/components.dart';

/// 常量类
class Constants {
  Constants._();

  /// 屏幕宽
  static const double screenWidth = 512;

  /// 屏幕高
  static const double screenHeight = 448;

  /// 屏幕尺寸
  static final Vector2 screenSize = Vector2(screenWidth, screenHeight);

  /// 菜单图片路径
  static const menuImagePath = "menu.gif";

  /// 资源图片路径
  static const resourceImagePath = "tankAll.gif";

  /// 菜单场景中的选择的坦克的图片坐标
  static final selectTankImagePosition = Vector2(128, 96);

  /// 关卡等级的图片坐标
  static final stageLevelImagePosition = Vector2(396, 96);

  /// 数字图片坐标
  static final numImagePosition = Vector2(256, 96);

  /// 地图地块图片坐标
  static final mapLandMassImagePosition = Vector2(0, 96);

  /// 玩家总部的图片坐标
  static final homeImagePosition = Vector2(256, 0);

  /// 玩家得分的图片坐标
  static final scoreImagePosition = Vector2(0, 112);

  /// 玩家的图片坐标
  static final playerImagePosition = Vector2(0, 0);

  /// 保护罩的图片坐标
  static final protectedImagePosition = Vector2(160, 96);

  /// 敌人坦克出生时的图片坐标
  static final enemyBornImagePosition = Vector2(256, 32);

  /// 敌人坦克1的图片坐标
  static final enemy1ImagePosition = Vector2(0, 32);

  /// 敌人坦克2的图片坐标
  static final enemy2ImagePosition = Vector2(128, 32);

  /// 敌人坦克3的图片坐标
  static final enemy3ImagePosition = Vector2(0, 64);

  /// 子弹的图片坐标
  static final bulletImagePosition = Vector2(80, 96);

  /// 坦克爆炸的图片坐标
  static final tankBombImagePosition = Vector2(0, 160);

  /// 子弹爆炸的图片坐标
  static final bulletBombImagePosition = Vector2(320, 0);

  /// 游戏结束的图片坐标
  static final overImagePosition = Vector2(384, 64);

  /// 道具的图片坐标
  static final propImagePosition = Vector2(256, 110);

  /*************************************
   *                                   *
   *        定义游戏中的常量              *
   *                                   *
   *************************************/

  /// 战斗中最大敌人数： 20
  static const maxWarEnemyCount = 20;

  /// 参与战斗的最多的敌人数： 5
  static const maxFightingEnemyCount = 5;
}
