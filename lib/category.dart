import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:udacity_project/Unit.dart';

class Category {
  final String name;
  final String icon;
  final ColorSwatch color;
  final List<Unit> units;

  const Category({
    @required this.name,
    @required this.icon,
    @required this.color,
    @required this.units,
  })
      : assert(name != null),
        assert(icon != null),
        assert(color != null),
        assert(units != null);
}
