import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'package:flutter/material.dart';

class AppStyles{

  static final appBarStyle = GoogleFonts.signika(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w100
  );

  static final hintTextStyle = GoogleFonts.signika(
    color: Color(0x9E5A5A5A),
    fontSize: 15,
    letterSpacing: 3
  );

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

  static final buttonText = GoogleFonts.signika(
      color: Colors.white,
      fontSize: 17,
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