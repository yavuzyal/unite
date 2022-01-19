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
    fontSize: 60,
  );

  static final profileName = GoogleFonts.nunito(
      color: AppColors.logoColor,
      fontSize: 40,
      fontWeight: FontWeight.w700
  );

  static final profileText = GoogleFonts.signika(
    color: AppColors.appTextColor,
    fontSize: 18,
  );

  static final profileTextName = GoogleFonts.signika(
    color: AppColors.appTextColor,
    fontWeight: FontWeight.w700,

    fontSize: 18,
  );

  static final commentName = GoogleFonts.signika(
    color: AppColors.appTextColor,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static final postText = GoogleFonts.signika(
    color: AppColors.postTextColor,
    fontSize: 18,
  );

  static final postOwnerText = GoogleFonts.signika(
    color: AppColors.postTextColor,
    fontWeight: FontWeight.w700,
    fontSize: 18,
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
    Color(0xFFF64CDA),
    Color(0xFF608BF7)
  ];

  static final colorizeTextStyle = GoogleFonts.signika(
    fontSize: 120,
  );
}

class darkAppStyles{

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
    color: Colors.black26,
    fontSize: 80,
  );

  static final appNamePage = GoogleFonts.signika(
    color: darkAppColors.logoColor,
    fontSize: 60,
  );

  static final profileName = GoogleFonts.nunito(
      color: darkAppColors.postTextColor,
      fontSize: 40,
      fontWeight: FontWeight.w700
  );

  static final profileText = GoogleFonts.signika(
    color: darkAppColors.appTextColor,
    fontSize: 18,
  );

  static final profileTextName = GoogleFonts.signika(
    color: darkAppColors.appTextColor,
    fontWeight: FontWeight.w700,

    fontSize: 18,
  );

  static final commentName = GoogleFonts.signika(
    color: darkAppColors.appTextColor,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static final postText = GoogleFonts.signika(
    color: darkAppColors.postTextColor,
    fontSize: 18,
  );

  static final postOwnerText = GoogleFonts.signika(
    color: darkAppColors.postTextColor,
    fontWeight: FontWeight.w700,
    fontSize: 18,
  );

  static final signUp = GoogleFonts.signika(
      color: darkAppColors.logoColor,
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
    Color(0xFFF64CDA),
    Color(0xFF608BF7)
  ];

  static final colorizeTextStyle = GoogleFonts.signika(
    fontSize: 120,
  );
}