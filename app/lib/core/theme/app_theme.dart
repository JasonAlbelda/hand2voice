import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Dark Mode Color Palette (inspired by the HTML reference)
  static const Color appBg = Color(0xFF101010);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color cardHover = Color(0xFF242424);
  static const Color textMain = Color(0xFFFFFFFF);
  static const Color textSub = Color(0xFF888888);
  static const Color accentPurple = Color(0xFFB366FF);
  static const Color accentTeal = Color(0xFF00E5FF);
  static const Color borderColor = Color(0xFF333333);
  static const Color primaryBtn = Color(0xFF3A86FF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: appBg,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: accentPurple,
        secondary: accentTeal,
        surface: cardBg,
        background: appBg,
        onPrimary: textMain,
        onSecondary: textMain,
        onSurface: textMain,
        onBackground: textMain,
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: appBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        iconTheme: IconThemeData(color: textMain),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBtn,
          foregroundColor: textMain,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPurple,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentPurple, width: 2),
        ),
        labelStyle: const TextStyle(color: textSub),
        hintStyle: const TextStyle(color: textSub),
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return textMain;
          }
          return textSub;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return accentTeal;
          }
          return borderColor;
        }),
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        iconColor: accentTeal,
        textColor: textMain,
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textMain),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textMain),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textMain),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textMain),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textMain),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textMain),
        bodyLarge: TextStyle(fontSize: 16, color: textMain),
        bodyMedium: TextStyle(fontSize: 14, color: textMain),
        bodySmall: TextStyle(fontSize: 13, color: textSub),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMain),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: accentTeal,
        size: 24,
      ),
    );
  }
}
