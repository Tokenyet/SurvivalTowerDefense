import 'dart:math' as Math;

import 'package:entitas_ff/entitas_ff.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:DarkSurviver/utilities/vector_2d.dart';

enum LightType {
  PointLight,
  SpotLight
}

abstract class Light {
  LightType get type;
  bool isBreath;

  Light({
    this.isBreath = true,
  });
  // List<Color> getLightColor(List<double> stop, Color lightEnvAmbient, );
}

class PointLight extends Light {
  final Color lightColor;
  final Vector2D worldPos;
  final double constance;
  final double linear;
  final double quadratic;
  
  PointLight({
    this.lightColor = Colors.white,
    this.worldPos,
    this.constance = 2.0,
    this.linear = 10.0,
    this.quadratic = 10.0,
    bool isBreath = true
  }) : super(isBreath: isBreath);

  @override
  LightType get type => LightType.PointLight;

  List<Color> getLightColor(List<double> stop, Color lightEnvAmbient, double maxDistance /*Vector2D attachedLightWorldPos, Rect worldRect*/) {
    // double distance = length(light.position - FragPos);
    // Vector2D topLeft = Vector2D.fromOffset(worldRect.topLeft);
    // Vector2D bottomLeft = Vector2D.fromOffset(worldRect.bottomLeft);
    // Vector2D topRight = Vector2D.fromOffset(worldRect.topRight);
    // Vector2D bottomRight = Vector2D.fromOffset(worldRect.bottomRight);
    // List<Vector2D> comparableVectors = [
    //   topLeft,
    //   bottomLeft,
    //   topRight,
    //   bottomRight
    // ];
    // double farestDistancePowerOf2 = 0;
    // for(int i = 0; i < comparableVectors.length; i++) {
    //   double distancePowerOf2 = (comparableVectors[i] - (attachedLightWorldPos ?? worldPos)).lengthOfPower2;
    //   if(farestDistancePowerOf2 < distancePowerOf2) {
    //     farestDistancePowerOf2 = distancePowerOf2;
    //   }
    // }

    // double maximumDistance = Math.sqrt(farestDistancePowerOf2);
    double maximumDistance = maxDistance;

    return stop.map<Color>((stop) {
      double distance = stop * maximumDistance;
      double attenuation = 1.0 / (constance + linear * distance + 
              quadratic * (distance * distance));    
      int r = Math.max((lightColor.red * attenuation).toInt(), lightEnvAmbient.red);
      int g = Math.max((lightColor.green * attenuation).toInt(), lightEnvAmbient.green);
      int b = Math.max((lightColor.blue * attenuation).toInt(), lightEnvAmbient.blue);
      int alpha = Math.min((lightColor.alpha * (1.0 - attenuation)).toInt(), lightEnvAmbient.alpha);
      return Color.fromRGBO(r, g, b, alpha / 255.0);
    }).toList();
  }
}


class SpotLight extends Light {
  final Color lightColor;
  final Vector2D worldPos;
  final double cutOff; // distance
  final double outerCutOffDiff; //
  final double ratio; // 1.0 => 90, but there is nothing 
  final bool isUseLocal; // local cutOff and outerCutOff

  SpotLight({
    this.lightColor = Colors.white,
    this.worldPos,
    this.ratio = 1.0,
    this.cutOff = 45,
    this.outerCutOffDiff = 8,
    this.isUseLocal = false,
    bool isBreath = true
  }) : super(isBreath: isBreath);

  
  List<Color> getLightColor(List<double> stop, Color lightEnvAmbient, double maxDistance, double maximumRadius) {
    double maximumDistance = maxDistance;
    double cutoff = maximumRadius ?? this.cutOff;
    double outerCutOff = this.cutOff + this.outerCutOffDiff;
    return stop.map<Color>((stop) {
      double distance = stop * maximumDistance;
      double theta = (maximumRadius * stop / 0.1); //dot(lightDir, normalize(-light.direction));
      double epsilon = cutoff - outerCutOff;
      double intensity = Math.min(Math.max((theta - outerCutOff) / epsilon, 0.0), 1.0);    

      if(distance < cutoff) return lightColor.withOpacity(0);

      int r = Math.max((lightColor.red * intensity).toInt(), lightEnvAmbient.red);
      int g = Math.max((lightColor.green * intensity).toInt(), lightEnvAmbient.green);
      int b = Math.max((lightColor.blue * intensity).toInt(), lightEnvAmbient.blue);
      int alpha = Math.min((lightColor.alpha * (1.0 - intensity)).toInt(), lightEnvAmbient.alpha);
      return Color.fromRGBO(r, g, b, alpha / 255.0);
    }).toList();
  }

  @override
  LightType get type => LightType.SpotLight;
}

class LightComp extends Component {
  final Light light; // use Radicalgradient
  LightComp({
    this.light,
  });
}
