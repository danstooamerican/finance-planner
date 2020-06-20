import 'package:flutter/cupertino.dart';
import 'package:financeplanner/extensions/extensions.dart';

class Category {
  final int id;
  final String name;
  final IconData icon;

  Category({
    @required this.id,
    @required this.name,
    @required this.icon,
  });

  Category.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        icon = _iconFromJson(json['icon']);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.toJson()
    };
  }

  static IconData _iconFromJson(Map<String, dynamic> json) {
    final int codePoint = json['codePoint'];
    final String fontFamily = json['fontFamily'];
    final String fontPackage = json['fontPackage'];

    return IconData(codePoint, fontFamily: fontFamily, fontPackage: fontPackage);
  }
}
