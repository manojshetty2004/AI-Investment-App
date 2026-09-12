import 'package:flutter/material.dart';

const appBorderColor = Color(0xFFE5E7EB);
const appAccentColor = Color(0xFF22C55E);
const appInkColor = Color(0xFF131C30);

/// Flat surfaces for every state, including pressed buttons and modal surfaces.
abstract final class AppTheme {
  static const buttonStyle = ButtonStyle(
    elevation: WidgetStatePropertyAll(0),
    shadowColor: WidgetStatePropertyAll(Colors.transparent),
    surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
    backgroundColor: WidgetStatePropertyAll(Colors.white),
    foregroundColor: WidgetStatePropertyAll(appInkColor),
    side: WidgetStatePropertyAll(BorderSide(color: appBorderColor)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: appAccentColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F9FB),
    shadowColor: Colors.transparent,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: Color(0xFFF1F5F9),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: appBorderColor),
      ),
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(style: buttonStyle),
    filledButtonTheme: const FilledButtonThemeData(style: buttonStyle),
    outlinedButtonTheme: const OutlinedButtonThemeData(style: buttonStyle),
    textButtonTheme: const TextButtonThemeData(style: buttonStyle),
    iconButtonTheme: const IconButtonThemeData(style: buttonStyle),
    chipTheme: const ChipThemeData(
      elevation: 0,
      pressElevation: 0,
      backgroundColor: Colors.white,
      selectedColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      side: BorderSide(color: appBorderColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      selectedItemColor: appAccentColor,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      elevation: 0,
      modalElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(color: appBorderColor),
      ),
    ),
    dialogTheme: const DialogThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: appBorderColor),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(elevation: 0),
  );
}
