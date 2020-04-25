import 'package:box2d_flame/box2d.dart';
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/box2d/viewport.dart';
import 'package:flutter/rendering.dart';

class Box2dDebuggerRender {
  static Box2dDebuggerRender _static;
  Box2dDebuggerRender._();

  static Box2dDebuggerRender getInstance() {
    if(_static == null) _static = Box2dDebuggerRender._();
    return _static;
  }



  void render(Canvas canvas, Body body, Viewport viewport) {
        body.getFixtureList();
    for (Fixture fixture = body.getFixtureList();
        fixture != null;
        fixture = fixture.getNext()) {
      switch (fixture.getType()) {
        case ShapeType.CHAIN:
          _renderChain(canvas, fixture, body, viewport);
          break;
        case ShapeType.CIRCLE:
          _renderCircle(canvas, fixture, body, viewport);
          break;
        case ShapeType.EDGE:
          throw Exception('not implemented');
          break;
        case ShapeType.POLYGON:
          _renderPolygon(canvas, fixture, body, viewport);
          break;
      }
    }
  }

  
  void _renderChain(Canvas canvas, Fixture fixture, Body body, Viewport viewport) {
    final ChainShape chainShape = fixture.getShape();
    final List<Vector2> vertices = Vec2Array().get(chainShape.getVertexCount());

    for (int i = 0; i < chainShape.getVertexCount(); ++i) {
      body.getWorldPointToOut(chainShape.getVertex(i), vertices[i]);
      vertices[i] = viewport.getWorldToScreen(vertices[i]);
    }

    final List<Offset> points = [];
    for (int i = 0; i < chainShape.getVertexCount(); i++) {
      points.add(Offset(vertices[i].x, vertices[i].y));
    }

    renderChain(canvas, points);
  }

  void renderChain(Canvas canvas, List<Offset> points) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, paint);
  }

  void _renderCircle(Canvas canvas, Fixture fixture, Body body, Viewport viewport) {
    var center = Vector2.zero();
    final CircleShape circle = fixture.getShape();
    body.getWorldPointToOut(circle.p, center);
    center = viewport.getWorldToScreen(center);
    renderCircle(
        canvas, Offset(center.x, center.y), circle.radius * viewport.scale);
  }

  void renderCircle(Canvas canvas, Offset center, double radius) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);
    canvas.drawCircle(center, radius, paint);
  }

  void _renderPolygon(Canvas canvas, Fixture fixture, Body body, Viewport viewport) {
    final PolygonShape polygon = fixture.getShape();
    assert(polygon.count <= BodyComponent.MAX_POLYGON_VERTICES);
    final List<Vector2> vertices = Vec2Array().get(polygon.count);

    for (int i = 0; i < polygon.count; ++i) {
      body.getWorldPointToOut(polygon.vertices[i], vertices[i]);
      vertices[i] = viewport.getWorldToScreen(vertices[i]);
    }

    final List<Offset> points = [];
    for (int i = 0; i < polygon.count; i++) {
      points.add(Offset(vertices[i].x, vertices[i].y));
    }

    renderPolygon(canvas, points);
  }

  void renderPolygon(Canvas canvas, List<Offset> points) {
    final path = Path()..addPolygon(points, true);
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);
    canvas.drawPath(path, paint);
  }
}