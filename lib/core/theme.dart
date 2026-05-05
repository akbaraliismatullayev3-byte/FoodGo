import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LumiereColors {
  static const Color orangePrimary = Color(0xFFFF5722);
  static const Color orangeLight = Color(0xFFFF7043);
  static const Color redAccent = Color(0xFFD32F2F);
  static const Color creamBg = Color(0xFFFFF9F1);
  static const Color darkGray = Color(0xFF333333);
  static const Color lightGray = Color(0xFF9E9E9E);
  static const Color glassWhite = Color(0xCCFFFFFF);
  
  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [orangePrimary, redAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softOverlay = LinearGradient(
    colors: [
      Color(0x80FFF9F1), // Cream with 50% opacity
      Color(0x80FF7043), // Orange with 50% opacity
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Category Gradients
  static const LinearGradient burgerGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient pizzaGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient sushiGradient = LinearGradient(
    colors: [Color(0xFF00BCD4), Color(0xFF006064)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient dessertGradient = LinearGradient(
    colors: [Color(0xFFE91E8C), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient allGradient = LinearGradient(
    colors: [Color(0xFF5C6BC0), Color(0xFF283593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: LumiereColors.creamBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: LumiereColors.orangePrimary,
        primary: LumiereColors.orangePrimary,
        secondary: LumiereColors.redAccent,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: LumiereColors.darkGray,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: LumiereColors.darkGray,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: LumiereColors.darkGray,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: LumiereColors.lightGray,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: LumiereColors.orangePrimary,
        primary: LumiereColors.orangePrimary,
        secondary: LumiereColors.redAccent,
        surface: const Color(0xFF1E1E1E),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

