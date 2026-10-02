import 'package:flutter/material.dart';

import 'ui/splash.dart';
import 'ui/style/theme.dart';

void main() {
  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.modo,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Caminhadas',
          theme: AppTheme.temaClaro,
          darkTheme: AppTheme.temaEscuro,
          themeMode: themeMode,
          home: const Splash(),
        );
      },
    ),
  );
}
