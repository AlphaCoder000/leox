import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AppTheme {
  // Light Theme Colors (Strict Match)
  static const Color primaryBlue = Color(0xFF0284C7); // Premium Azure Blue
  static const Color lightBackground = Color.fromRGBO(245, 247, 250, 1);
  static const Color white = Colors.white;
  static const Color primaryText = Color.fromRGBO(32, 33, 36, 1);
  static const Color secondaryText = Color.fromRGBO(95, 99, 104, 1);
  static const Color borderColor = Color.fromRGBO(224, 227, 231, 1);

  // Premium Unified Brand Gradient
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)], // Sky to Royal Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme Colors (Navy)
  static const Color darkBackground = Color(0xFF0F172A); // Dark Navy
  static const Color darkSurface = Color(0xFF1E293B); // Lighter Navy
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      dividerColor: borderColor,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: white,
        onSurface: primaryText,
        outline: borderColor,
        error: Colors.redAccent,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0, // "web-like" flat with border or slight shadow handled by widget
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderColor),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: primaryText),
        titleTextStyle: GoogleFonts.inter(
          color: primaryText,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: primaryText,
        displayColor: primaryText,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: white,
        surfaceTintColor: white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: secondaryText, fontSize: 13.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      dividerColor: const Color(0xFF334155),
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        outline: Color(0xFF334155),
        error: Colors.redAccent,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF334155)),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: darkTextPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkBackground, 
        surfaceTintColor: darkBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        hintStyle: TextStyle(color: darkTextSecondary, fontSize: 13.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
