import 'package:flutter/material.dart';

/// Text styles using Quicksand font from assets

class AppTextStyles {
  static TextStyle h1({Color? color}) => TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color ?? Colors.grey.shade900,
      );

  static TextStyle h2({Color? color}) => TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color ?? Colors.grey.shade900,
      );

  static TextStyle h3({Color? color}) => TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.grey.shade900,
      );

  static TextStyle body({Color? color}) => TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 14,
        color: color ?? Colors.grey.shade900,
      );

  static TextStyle bodySmall({Color? color}) => TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 12,
        color: color ?? Colors.grey.shade600,
      );

  static TextStyle label({Color? color}) => TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color ?? Colors.grey.shade700,
      );

  static TextStyle link({Color? color}) => TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: color ?? const Color(0xFFFF9500),
      );
}
