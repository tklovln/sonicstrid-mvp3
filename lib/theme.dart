
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/* For the union of color through whole project, I defined 2 base color theme: MyTheme and MoodSelectTheme*/

class MyThemes {
  static final ThemeData customTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFF6B17), 
    useMaterial3: true,
    colorScheme: CustomColorScheme.customColorTheme,
    textTheme: CustomTextScheme.customTextTheme,
  );
}

class MoodSelectTheme {
  static final ThemeData customTheme = ThemeData(
    scaffoldBackgroundColor:Colors.black, 
    useMaterial3: true,
    colorScheme: CustomColorScheme.orangeColorTheme,
    textTheme: CustomTextScheme.customTextTheme,
    cardTheme: CustomCardTheme.customCardTheme,
  );
}

class CustomCardTheme {
  static CardTheme customCardTheme = CardTheme(
    color: Colors.blue
  );
}

// Orange basis background
class CustomColorScheme {

  static ColorScheme customColorTheme = const ColorScheme(
    
    background: Color(0xFFFF6B17), // Custom background color
    primary: Colors.black, // Custom primary color
    primaryContainer: Colors.black, // Custom variant of primary color
    secondary: Colors.green, // Custom secondary color
    secondaryContainer: Colors.greenAccent, // Custom variant of secondary color
    surface: Colors.grey, // Custom surface color
    error: Colors.red, // Custom error color
    onPrimary: Colors.white, // Custom text color on primary background
    onSecondary: Colors.red, // Custom text color on secondary background
    onSurface: Colors.yellow, // Custom text color on surface background
    onBackground: Colors.purple, // Custom text color on background
    onError: Colors.white, // Custom text color on error background
    brightness: Brightness.light, // Brightness setting, can be Brightness.light or Brightness.dark
  );

  static ColorScheme orangeColorTheme = const ColorScheme(
    background: Colors.black, // Custom background color
    primary: Color(0xFFFF6B17), // Custom primary color
    primaryContainer: Colors.black, // Bottom part of the song select paga background
    secondary: Colors.green, // Custom secondary color
    secondaryContainer: Colors.greenAccent, // Custom variant of secondary color
    surface: Colors.grey, // Custom surface color
    error: Colors.red, // Custom error color
    onPrimary: Colors.white, // Custom text color on primary background
    onSecondary: Colors.black, // Custom text color on secondary background
    onSurface: Colors.black, // Custom text color on surface background
    onBackground: Colors.black, // Custom text color on background
    onError: Colors.white, // Custom text color on error background
    brightness: Brightness.light, // Brightness setting, can be Brightness.light or Brightness.dark
  );
}

class CustomTextScheme {
  static TextTheme customTextTheme = TextTheme(
    displayLarge: const TextStyle(
      fontSize: 32.0, // Custom font size for headline1
      fontWeight: FontWeight.bold, // Custom font weight for headline1
      color: Colors.blue, // Custom color for headline1
    ),
    
    // Music Player Page
    titleLarge: GoogleFonts.biryani( // Count down
              fontSize:72,
              color: Colors.white, //Colors.grey.shade700,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.6,),
    titleMedium: GoogleFonts.biryani( // Music Player Timer
              fontSize:58,
              color: Colors.white, // Colors.grey.shade700,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.6,),
    titleSmall: GoogleFonts.biryani( // Music Player Timer
              fontSize:36,
              color: Colors.white, // Colors.grey.shade700,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.6,),

    // Login Page
    headlineLarge: GoogleFonts.lato( 
              fontSize:32,
              color: Color(0xFF2D2D2D), 
              fontWeight: FontWeight.w400,
              letterSpacing: 2.6,),
    headlineSmall: GoogleFonts.lato( 
              fontSize:16,
              color: Color(0xFF2D2D2D), 
              fontWeight: FontWeight.w400,
              letterSpacing: 2.6,),

    bodyLarge: GoogleFonts.biryani( // MusicPlayer Distance value, Sync rate value.....
              fontSize: 36,
              color: Colors.white, // Colors.grey.shade700,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.6,),
    
    bodyMedium: GoogleFonts.biryani(
              fontSize: 13,
              color: Colors.white, //Colors.grey.shade700,
              fontWeight: FontWeight.w400,
              letterSpacing: 2.6,),
              
    bodySmall: TextStyle(
      fontSize: 12.0, 
      color: Colors.white60, 
    ),
  );

}
