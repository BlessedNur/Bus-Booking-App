import 'package:flutter/material.dart';

/// Helper function to get Quicksand font style
/// Uses Flutter font assets from pubspec.yaml
TextStyle quicksand({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
  TextDecoration? textDecoration,
  Color? decorationColor,
}) {
  return TextStyle(
    fontFamily: 'Quicksand',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    decoration: textDecoration,
    decorationColor: decorationColor,
  );
}
