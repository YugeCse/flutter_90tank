import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_90tank/data/constants.dart';
import 'package:flutter_90tank/scene/tank_war_scene.dart';
import 'package:flutter_90tank/tank_game.dart';
import 'package:flutter_90tank/widget/map_component.dart';
import 'package:flutter_90tank/widget/tank_component.dart';

/// 数据展示组件
class DataComponent extends PositionComponent with HasGameRef<TankGame> {
  DataComponent({super.size, super.position}) {
    size = Vector2(
      MapComponent.warTileSize.x * 2,
      TankWarScene.warGroundSize.y,
    );
  }

  /// 敌人坦克精灵，用于展示敌人坦克数量
  final List<Component> enemyTanks = [];

  /// 英雄坦克生命值文本
  TextComponent? _heroTankLifeText;

  /// 英雄2坦克生命值文本
  TextComponent? _hero2TankLifeText;

  /// 当前关卡等级文本
  TextComponent? _stageLevelText;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    for (var i = 0; i < Constants.maxWarEnemyCount; i++) {
      var x = i % 2;
      var y = i ~/ 2;
      var tank = SpriteComponent.fromImage(
        gameRef.resImage,
        srcSize: MapComponent.warTileSize,
        srcPosition: Vector2(92.3, 110),
        position: Vector2(
          x * MapComponent.warTileSize.x,
          y * MapComponent.warTileSize.y,
        ),
      );
      enemyTanks.add(tank);
      add(tank); // 添加到场景中
    }
    add(
      SpriteComponent.fromImage(
        gameRef.resImage,
        srcPosition: Vector2(0, 112),
        srcSize: MapComponent.warTileSize * 1.8,
        position: Vector2(0, MapComponent.warTileSize.y * 15),
      ),
    );
    add(
      _heroTankLifeText = TextComponent(
        text: "3",
        position: Vector2(
          MapComponent.warTileSize.y * 1.2,
          MapComponent.warTileSize.y * 16,
        ),
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
    add(
      SpriteComponent.fromImage(
        gameRef.resImage,
        srcPosition: Vector2(30, 112),
        srcSize: MapComponent.warTileSize * 1.8,
        position: Vector2(0, MapComponent.warTileSize.y * 18),
      ),
    );
    add(
      _hero2TankLifeText = TextComponent(
        text: "0",
        position: Vector2(
          MapComponent.warTileSize.y * 1.2,
          MapComponent.warTileSize.y * 19,
        ),
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
    add(
      SpriteComponent.fromImage(
        gameRef.resImage,
        srcPosition: Vector2(60, 112),
        srcSize: MapComponent.warTileSize * 1.8,
        position: Vector2(0, MapComponent.warTileSize.y * 22),
      ),
    );
    add(
      _stageLevelText = TextComponent(
        text: "0",
        position: Vector2(
          MapComponent.warTileSize.y * 1.2,
          MapComponent.warTileSize.y * 23,
        ),
        textRenderer: TextPaint(
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateEnemyTankShow(); //更新敌人坦克数量显示
    _heroTankLifeText?.text =
        gameRef.tankWarScene?.mapComponent.heroTankLifeCount.toString() ?? "0";
    _hero2TankLifeText?.text = "0";
    _stageLevelText?.text =
        ((gameRef.tankWarScene?.mapComponent.stage ?? 0) + 1).toString();
  }

  /// 更新敌人坦克数量显示
  void _updateEnemyTankShow() {
    if (enemyTanks.isEmpty) return; // 没有敌人坦克精灵，直接返回
    var diffCount =
        Constants.maxWarEnemyCount -
        (gameRef.tankWarScene?.mapComponent.destroyEnemyTankCount ?? 0) -
        (gameRef.tankWarScene?.mapComponent.children
                .whereType<EnemyTankComponent>()
                .length ??
            0);
    if (enemyTanks.length != diffCount && enemyTanks.isNotEmpty) {
      var count = enemyTanks.length - diffCount;
      var tanks = enemyTanks.sublist(enemyTanks.length - count);
      for (var tank in tanks) {
        remove(tank);
      }
      enemyTanks.removeRange(enemyTanks.length - count, enemyTanks.length);
    }
  }
}
