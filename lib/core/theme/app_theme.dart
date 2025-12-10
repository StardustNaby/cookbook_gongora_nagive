import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Coquette Color Palette - Rosas pastel y colores suaves
  static const Color primaryPink = Color(0xFFFFB6C1); // Light Pink
  static const Color accentPink = Color(0xFFFF91A4); // Stronger Pink
  static const Color softPink = Color(0xFFFFE4E9); // Very Light Pink
  static const Color rosePink = Color(0xFFFFC0CB); // Rose Pink
  static const Color lavenderPink = Color(0xFFF8BBD0); // Lavender Pink
  static const Color peachPink = Color(0xFFFFDAB9); // Peach Pink
  static const Color cream = Color(0xFFFFF8F0); // Cream
  static const Color mintGreen = Color(0xFFE0F2E7); // Mint Green
  static const Color softLavender = Color(0xFFE6E6FA); // Lavender
  static const Color borderPink = Color(0xFFFF69B4); // Hot Pink for borders

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.poppinsTextTheme();
    final titleTheme = GoogleFonts.dancingScriptTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryPink,
        secondary: accentPink,
        tertiary: lavenderPink,
        surface: Colors.white,
        error: Colors.red.shade300,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: cream,
      textTheme: textTheme.copyWith(
        displayLarge: titleTheme.displayLarge?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: titleTheme.displayMedium?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: titleTheme.displaySmall?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: titleTheme.headlineLarge?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: titleTheme.headlineMedium?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: titleTheme.headlineSmall?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: titleTheme.titleLarge?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: Colors.black87,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          color: Colors.black87,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: softPink,
        foregroundColor: accentPink,
        titleTextStyle: titleTheme.titleLarge?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: borderPink,
            width: 2,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPink,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(
              color: borderPink,
              width: 2,
            ),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentPink,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentPink,
          side: const BorderSide(
            color: borderPink,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: borderPink,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: borderPink,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: accentPink,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: Colors.red.shade300,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.poppins(
          color: accentPink,
        ),
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentPink,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: borderPink,
            width: 2,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: softPink,
        selectedColor: accentPink,
        labelStyle: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: borderPink,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    final titleTheme = GoogleFonts.dancingScriptTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryPink,
        secondary: accentPink,
        tertiary: lavenderPink,
        surface: const Color(0xFF2D2D2D),
        error: Colors.red.shade300,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      textTheme: textTheme.copyWith(
        displayLarge: titleTheme.displayLarge?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: titleTheme.displayMedium?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: titleTheme.displaySmall?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: titleTheme.headlineLarge?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: titleTheme.headlineMedium?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: titleTheme.headlineSmall?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: titleTheme.titleLarge?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF2D2D2D),
        foregroundColor: accentPink,
        titleTextStyle: titleTheme.titleLarge?.copyWith(
          color: accentPink,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D2D),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: borderPink,
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentPink,
          foregroundColor: Colors.white,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(
              color: borderPink,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
