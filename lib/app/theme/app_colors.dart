import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary
  static const Color notionBlack = Color(0xF2000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color notionBlue = Color(0xFF0075DE);

  // Brand Secondary
  static const Color deepNavy = Color(0xFF213183);
  static const Color activeBlue = Color(0xFF005BAB);

  // Warm Neutral Scale
  static const Color warmWhite = Color(0xFFF6F5F4);
  static const Color warmDark = Color(0xFF31302E);
  static const Color warmGray500 = Color(0xFF615D59);
  static const Color warmGray300 = Color(0xFFA39E98);

  // Semantic
  static const Color teal = Color(0xFF2A9D99);
  static const Color green = Color(0xFF1AAE39);
  static const Color orange = Color(0xFFDD5B00);
  static const Color error = Color(0xFFDC2626);

  // Interactive
  static const Color focusBlue = Color(0xFF097FE8);
  static const Color badgeBlueBg = Color(0xFFF2F9FF);
  static const Color badgeBlueText = Color(0xFF097FE8);

  // Border
  static const Color whisperBorder = Color(0x1A000000);

  // Shadows
  static List<BoxShadow> get cardShadow => const [
    BoxShadow(color: Color(0x0A000000), blurRadius: 18, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x07000000), blurRadius: 7.84688, offset: Offset(0, 2.025)),
    BoxShadow(color: Color(0x05000000), blurRadius: 2.925, offset: Offset(0, 0.8)),
    BoxShadow(color: Color(0x03000000), blurRadius: 1.04062, offset: Offset(0, 0.175)),
  ];

  static List<BoxShadow> get deepShadow => const [
    BoxShadow(color: Color(0x03000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x05000000), blurRadius: 7, offset: Offset(0, 3)),
    BoxShadow(color: Color(0x05000000), blurRadius: 15, offset: Offset(0, 7)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 28, offset: Offset(0, 14)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 52, offset: Offset(0, 23)),
  ];
}
