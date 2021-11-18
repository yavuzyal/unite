import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'package:flutter/material.dart';

class AppStyles{
  static final appNameMainPage = GoogleFonts.signika(
    color: AppColors.logoColor,
    fontSize: 80,
  );

  static final appNamePage = GoogleFonts.signika(
    color: AppColors.logoColor,
    fontSize: 50,
  );

  static final signUp = GoogleFonts.signika(
    color: AppColors.logoColor,
    fontSize: 17,
    fontWeight: FontWeight.w700
  );

  static final colorizeColors = [
    Color(0xFF60A8F7),
    Color(0xFF9947EE),
    Color(0xFFF64C6D),
    Color(0xFF608BF7)
  ];

  static final colorizeTextStyle = GoogleFonts.signika(
      fontSize: 120,
  );
}