import 'package:flutter/material.dart';

class AppColors {
  static const Color blueGrey = Color(0xFF758592);
  static const Color blue = Color(0xFF00A0DF);
  static const Color darkBlue = Color(0xFF0075A9);
  static const Color orange = Color(0xFFFF8300);
  static const Color orangeLight = Color(0xFFFFAB4D);
  static const Color orangeLighter = Color(0xFFFFC56D);
  static const Color orangePale = Color(0xFFFFDFC1);
  static const Color darkBlueDarker = Color(0xFF00285C);

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color red = Color(0xFFF44336);
  static const Color green = Color(0xFF4CAF50);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: AppColors.blue,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme(
        primary: AppColors.blue,
        primaryContainer: AppColors.darkBlue,
        secondary: AppColors.orange,
        surface: AppColors.white,
        error: AppColors.orange,
        onPrimary: AppColors.white,
        onPrimaryContainer: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.black,
        onError: AppColors.white,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w500,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        labelStyle: TextStyle(color: AppColors.black),
        border: UnderlineInputBorder(),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blue),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.blue,
        selectionColor: AppColors.blueGrey,
        selectionHandleColor: AppColors.darkBlue,
      ),
    );
  }

  static _AppThemeColors of(BuildContext context) => _AppThemeColors();
}

class _AppThemeColors {
  final Color primaryColor = AppColors.blue;
  final Color primaryDarkColor = AppColors.darkBlue;
  final Color secondaryColor = AppColors.blueGrey;
  final Color accentColor = AppColors.orange;
  final Color successLightColor = AppColors.orangeLight;
  final Color errorColor = AppColors.orange;
  final Color backgroundColor = AppColors.white;
  final Color cardColor = AppColors.orangePale;
  final Color textColor = AppColors.black;
  final Color iconColor = AppColors.blueGrey;
  final Color dividerColor = AppColors.blueGrey.withOpacity(0.2);
  final Color shadowColor = AppColors.blueGrey.withOpacity(0.2);
  final Color darkBlueDarker = AppColors.darkBlueDarker;

  List<Color> get orangeGradient => [
        AppColors.orange,
        AppColors.orangeLight,
        AppColors.orangeLighter,
        AppColors.orangePale,
      ];
}
