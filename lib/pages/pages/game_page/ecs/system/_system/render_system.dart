import 'dart:math' as Math;
import 'dart:ui';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/health_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/input_mouse_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/system/removable_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/terrain_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/lights/light.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/tower.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
// import 'package:DarkSurviver/pages/ecs/component/sprite_comp.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:box2d_flame/box2d.dart' as B2D;
import 'package:flutter/material.dart' hide Animation;

extension PaintExtension on Paint {
  copyWith({
    BlendMode blendMode,
    Color color,
    ColorFilter colorFilter,
    FilterQuality filterQuality,
    ImageFilter imageFilter,
    bool invertColors,
    bool isAntiAlias,
    MaskFilter maskFilter,
    Shader shader,
    StrokeCap strokeCap,
    StrokeJoin strokeJoin,
    double strokeMiterLimit,
    double strokeWidth,
    PaintingStyle style
  }) {
    return Paint()
      ..blendMode = blendMode ?? this.blendMode
      ..color = color ?? this.color
      ..colorFilter = colorFilter ?? this.colorFilter
      ..filterQuality = filterQuality ?? this.filterQuality
      ..imageFilter = imageFilter ?? this.imageFilter
      ..invertColors = invertColors ?? this.invertColors
      ..isAntiAlias = isAntiAlias ?? this.isAntiAlias
      ..maskFilter = maskFilter ?? this.maskFilter
      ..shader = shader ?? this.shader
      ..strokeCap = strokeCap ?? this.strokeCap
      ..strokeJoin = strokeJoin ?? this.strokeJoin
      ..strokeMiterLimit = strokeMiterLimit ?? this.strokeMiterLimit
      ..strokeWidth = strokeWidth ?? this.strokeWidth
      ..style = style ?? this.style;
  }
}

class RenderSystem extends ExecuteSystem {
  RenderSystem._();

  static RenderSystem _instance;

  static getInstance() {
    if(_instance == null) _instance = RenderSystem._();
    return _instance;
  }

  Box2D box2d;
  EntityManager em;
  // Sprite terrainSprite;
  Color lightEnviromentAmbient;
  Paint lightPaint;
  init(Box2D box2d, EntityManager em) {
    this.box2d = box2d;
    this.em = em;
    this.lightEnviromentAmbient = Colors.black54;
    this.lightPaint = Paint()
      ..blendMode = BlendMode.dstATop;
  }

  render(Canvas canvas) {    
    DateTime currentTime = DateTime.now();
    Group terrainGroup = em.group(all: [TerrainComp]);
    // print(Math.sin(currentTime.millisecond.toDouble() / 1000));
    for(Entity e in terrainGroup.entities) {
      if(e.has(PropertyComp)) {
        if(e.get<AnimatableComp>().info.currentAnimKey == TerrainState.UNPLANTED_SELECT.toString()) {
          doDrawing(canvas, e.get<AnimatableComp>(), e.get<PropertyComp>(), currentTime, isSelected: true);
        } else {
          doDrawing(canvas, e.get<AnimatableComp>(), e.get<PropertyComp>(), currentTime);
        }
      }
    }
    Group animatableGroup = em.group(all: [AnimatableComp], none: [TerrainComp]);
    for(Entity e in animatableGroup.entities) {
      doDrawing(canvas, e.get<AnimatableComp>(), e.get<PropertyComp>(), currentTime);
    }
    
    Group healthGroup = em.group(all: [HealthComp]);
    for(Entity e in healthGroup.entities) {
      if(!e.get<HealthComp>().health.isDisplay) continue;
      if(e.has(PropertyComp)) {
        double width = e.get<PropertyComp>().width;
        double height = e.get<PropertyComp>().height;
        double x = e.get<PropertyComp>().x;
        double y = e.get<PropertyComp>().y;
        double percent = e.get<HealthComp>().health.currentHp.toDouble() / e.get<HealthComp>().health.maximumHp.toDouble();
        // canvas.drawRect(Offset(x - width / 2 - 5, y - height / 2 - 2) & Size(width + 10, 14), Paint()..color = Colors.white);
        // canvas.drawRect(Offset(x - width / 2, y - height / 2) & Size(width, 10), Paint()..color = Colors.grey);
        // canvas.drawRect(Offset(x - width / 2, y - height / 2) & Size(width * percent, 10), Paint()..color = Colors.green);
        canvas.drawRect(Offset(x - width / 2 - 5, y - height / 2 - 14) & Size(width + 10, 14), Paint()..color = Colors.white);
        canvas.drawRect(Offset(x - width / 2, y - height / 2 - 12) & Size(width, 10), Paint()..color = Colors.grey);
        canvas.drawRect(Offset(x - width / 2, y - height / 2 - 12) & Size(width * percent, 10), Paint()..color = Colors.green);
      }
    }

    // Test Renderering
    // RenderLightTest(canvas);

    // Group lightGroup = em.group(all: [LightComp]);
    // renderLights(canvas, lightGroup.entities, currentTime);
  }

  void renderLights(Canvas canvas, List<Entity> lights, DateTime currentTime) {
    canvas.saveLayer(null, Paint()); // 不能用 canvas.save
    canvas.drawColor(lightEnviromentAmbient, BlendMode.src);
    Rect worldRect = Vector2D.fromVector2(box2d.viewport.center).toOffset() & box2d.viewport.size;
    for(Entity e in lights) {
      PropertyComp comp = e.get<PropertyComp>();
      LightComp lightComp = e.get<LightComp>();
      // double centerx = comp.x + comp.width / 2;
      // double centery = comp.y + comp.height / 2;
      doLight(
        canvas,
        lightComp,
        Vector2D.fromVector2(box2d.viewport.getScreenToWorld(Vector2D(comp.x, comp.y).toVector2())),
        currentTime,
        worldRect,
        spotLightRadius: Math.max(comp.width, comp.height) / box2d.viewport.scale,
        isBreath: lightComp.light.isBreath
      );
    }
    canvas.restore();
  }

  void doLight(Canvas canvas, LightComp comp, Vector2D lightWorldPos, DateTime currentTime, Rect worldRect, {double spotLightRadius, bool isBreath}) {
    const List<double> predefinedStops = [0, 0.7, 0.8, 0.9, 1.0];
    Light light = comp.light;
    List<Color> colors;
    double breathFactor = isBreath == true ? (1.0 - Math.cos(currentTime.millisecondsSinceEpoch.toDouble() / 500) * 0.05 + 0.05) : 1.0;
    double maximumDistance = _calculatePointLight(lightWorldPos, worldRect); // world maximum radius from object

    maximumDistance *= breathFactor;
    spotLightRadius *= breathFactor;

    if(light is PointLight) {
      colors = light.getLightColor(predefinedStops, lightEnviromentAmbient, maximumDistance);
    } else if(light is SpotLight) {
      colors = light.getLightColor(predefinedStops, lightEnviromentAmbient, maximumDistance, spotLightRadius);
      maximumDistance = spotLightRadius * box2d.viewport.scale; // body to screen radius
    }

    Vector2D lightScreenPos = Vector2D.fromVector2(box2d.viewport.getWorldToScreen(lightWorldPos.toVector2()));
    lightPaint.blendMode = BlendMode.dstATop;
    lightPaint.shader = RadialGradient(
      //colors: [Colors.transparent, Colors.transparent, Colors.black12, Colors.black45, lightEnviromentAmbient,],
      colors: colors,
      stops: predefinedStops
    ).createShader(Rect.fromCircle(center: lightScreenPos.toOffset(),radius: maximumDistance));
    canvas.drawCircle(lightScreenPos.toOffset(), maximumDistance, lightPaint);
  }

  double _calculatePointLight(Vector2D lightPos, Rect worldRect) {
    Vector2D topLeft = Vector2D.fromOffset(worldRect.topLeft);
    Vector2D bottomLeft = Vector2D.fromOffset(worldRect.bottomLeft);
    Vector2D topRight = Vector2D.fromOffset(worldRect.topRight);
    Vector2D bottomRight = Vector2D.fromOffset(worldRect.bottomRight);
    List<Vector2D> comparableVectors = [
      topLeft,
      bottomLeft,
      topRight,
      bottomRight
    ];
    double farestDistancePowerOf2 = 0;
    for(int i = 0; i < comparableVectors.length; i++) {
      double distancePowerOf2 = (comparableVectors[i] - lightPos).lengthOfPower2;
      if(farestDistancePowerOf2 < distancePowerOf2) {
        farestDistancePowerOf2 = distancePowerOf2;
      }
    }

    return Math.sqrt(farestDistancePowerOf2);
  }

  void RenderLightTest(Canvas canvas) {
    Paint circlePaint = Paint();
    Paint maskPaint = Paint();
    // save => transformation and clips
    // savelayer => include save, but also save previous canvas as a layer
    canvas.saveLayer(null, Paint()); // 不能用 canvas.save
    // canvas.drawCircle(Offset(80, 80), 64, Paint()
    //   ..color = Colors.white
    //   ..blendMode = BlendMode.srcIn);
    circlePaint.style = PaintingStyle.fill;
    circlePaint.color = Colors.yellow;
    maskPaint.blendMode = BlendMode.dstATop;
    maskPaint.color = Colors.white;
    maskPaint.shader = RadialGradient(
      colors: [Colors.transparent, Colors.transparent, Colors.black12, Colors.black45, Colors.black87,],
      stops: [0, 0.7, 0.8, 0.9, 1.0]
    ).createShader(Rect.fromCircle(center: Offset(80, 80),radius: 256));
    canvas.drawColor(Colors.black87, BlendMode.src);
    // canvas.drawColor(Colors.transparent, BlendMode.srcIn);
    // canvas.drawCircle(Offset(80, 80), 64, circlePaint);
    canvas.drawCircle(Offset(80, 80), 256, maskPaint);
    canvas.restore();

  }

  Paint _applyAlphaEffect(Animation animation, DateTime currentTime) {
    return animation.paint.copyWith(
      color: animation.paint.color.withOpacity(Math.sin(currentTime.millisecondsSinceEpoch.toDouble() / 200) * 0.25 + 0.75)
    );
  }

  doDrawing(Canvas canvas, AnimatableComp animatableComp, PropertyComp propertyComp, DateTime currentTime, {bool isSelected = false}) {
    Paint originalPaint = animatableComp.info.currentAnim.paint;
    Paint targetPaint = originalPaint;
    if(isSelected) targetPaint = _applyAlphaEffect(animatableComp.info.currentAnim, currentTime);

    animatableComp.info.currentAnim.paint = targetPaint;
    animatableComp.info.currentAnim.execute(canvas, propertyComp);

    animatableComp.info.currentAnim.paint = originalPaint;
  }

  @override
  execute() {
    return null;
  }
}