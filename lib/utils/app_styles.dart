import 'package:flutter/material.dart';

/// App Styles - Tailwind-like utility classes for easy styling
/// Similar to Tailwind CSS for Flutter

class AppStyles {
  // Colors
  static const Color primary = Color(0xFFFF9500);
  static const Color background = Color(0xFFF5F5F5);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Text Styles - Quicksand font (from assets)
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 12,
    color: textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle link = TextStyle(
    fontFamily: 'Quicksand',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: primary,
  );

  // Spacing utilities
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Border radius
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
}

/// Helper extension for easy styling (similar to Tailwind)
extension StyledWidget on Widget {
  Widget padding(double value) => Padding(
        padding: EdgeInsets.all(value),
      );

  Widget px(double value) => Padding(
        padding: EdgeInsets.symmetric(horizontal: value),
      );

  Widget py(double value) => Padding(
        padding: EdgeInsets.symmetric(vertical: value),
      );

  Widget pt(double value) => Padding(
        padding: EdgeInsets.only(top: value),
      );

  Widget pb(double value) => Padding(
        padding: EdgeInsets.only(bottom: value),
      );

  Widget pl(double value) => Padding(
        padding: EdgeInsets.only(left: value),
      );

  Widget pr(double value) => Padding(
        padding: EdgeInsets.only(right: value),
      );

  Widget rounded(double radius) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: this,
      );

  Widget centered() => Center(child: this);

  Widget fullWidth() => SizedBox(width: double.infinity, child: this);

  Widget sized({double? width, double? height}) => SizedBox(
        width: width,
        height: height,
        child: this,
      );
}

/// Helper for creating styled Text widgets easily
class StyledText {
  static Widget h1(String text, {Color? color}) => Text(
        text,
        style: AppStyles.h1.copyWith(color: color),
      );

  static Widget h2(String text, {Color? color}) => Text(
        text,
        style: AppStyles.h2.copyWith(color: color),
      );

  static Widget h3(String text, {Color? color}) => Text(
        text,
        style: AppStyles.h3.copyWith(color: color),
      );

  static Widget body(String text, {Color? color}) => Text(
        text,
        style: AppStyles.body.copyWith(color: color),
      );

  static Widget label(String text, {Color? color}) => Text(
        text,
        style: AppStyles.label.copyWith(color: color),
      );

  static Widget link(String text, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: AppStyles.link,
        ),
      );
}
