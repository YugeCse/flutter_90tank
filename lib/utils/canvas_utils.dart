import 'dart:ui' show Image;

import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_90tank/data/constants.dart' show Constants;
import 'package:flutter_90tank/data/land_mass_type.dart' show LandMassType;

extension CanvasUtils on Canvas {
  /// 绘制战场图块
  void drawMapTile({
    required Image resImage,
    required int column,
    required int row,
    required Vector2 tileSize,
    required LandMassType type,
  }) {
    final paint = Paint();
    var tileRect = Rect.fromLTWH(
      column * tileSize.x,
      row * tileSize.y,
      tileSize.x,
      tileSize.y,
    );
    var landMassPos = Constants.mapLandMassImagePosition;
    var srcRect = (landMassPos + Vector2(type.imageIndex * tileSize.x, 0))
        .toPositionedRect(tileSize);
    drawImageRect(resImage, srcRect, tileRect, paint);
  }
}
