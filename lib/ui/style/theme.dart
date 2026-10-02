import 'package:flutter/material.dart';
import 'colors.dart';

abstract class AppTheme {
  static final ValueNotifier<ThemeMode> modo = ValueNotifier(ThemeMode.light);

  static void alternarTema() {
    modo.value = modo.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  static ThemeData temaClaro = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppColors.c5,
    primaryColor: AppColors.c1,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.c1),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.c1,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.c1,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.c1,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );

  static ThemeData temaEscuro = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF102A2E),
    primaryColor: AppColors.c3,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.c2, brightness: Brightness.dark),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.c1,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.c2,
      foregroundColor: Colors.white,
    ),
  );
}
