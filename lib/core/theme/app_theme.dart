import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0A1931);
  static const Color accentColor = Color(0xFF38E54D);
  static const Color secondaryAccentColor = Color(0xFF2563EB); // Azul brillante
  static const Color backgroundColor = Color(0xFFF0F2F5);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF1E293B);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF183D5D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [secondaryAccentColor, Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // --- CORRECCIÓN CLAVE AQUÍ ---
    // La clase correcta es 'CardThemeData', no 'CardTheme'.
    cardTheme: CardThemeData(
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(secondaryAccentColor),
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        padding: WidgetStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevation: WidgetStateProperty.all<double>(4),
        shadowColor: WidgetStateProperty.all<Color>(secondaryAccentColor.withOpacity(0.4)),
      ),
    ),
    
    // Estilo para los campos de texto
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondaryAccentColor, width: 2),
      ),
      floatingLabelStyle: const TextStyle(color: secondaryAccentColor),
      prefixIconColor: Colors.grey.shade600,
    ),
  );
}