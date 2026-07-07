import 'package:flutter/material.dart';

class AppColors {
  // Palette principale
  static const primary = Color.fromARGB(255, 4, 77, 22);      // Vert du logo
  static const primaryDark = Color(0xFF24574D);  // Vert foncé

  // Doré du logo
  static const accent = Color(0xFFD9B15A);

  // Fonds
  static const background = Color(0xFFF8FAF8);
  static const surface = Colors.white;

  // Texte
  static const text = Color(0xFF1F2937);
  static const muted = Color(0xFF6B7280);

  // États
  static const success = Color(0xFF2F6F63);
  static const successSoft = Color(0xFFE7F5F2);

  static const finished = Color(0xFFD4A84F);
  static const finishedSoft = Color(0xFFFBF5E8);

  static const warning = Color(0xFFE67E22);
  static const warningSoft = Color(0xFFFFF3E0);

  static const danger = Color(0xFFC62828);
  static const dangerSoft = Color(0xFFFDECEC);
}
class AppTheme {
  static ThemeData light() {
    final scheme = const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: AppColors.text,

    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: AppColors.primaryDark,
          ),
          titleTextStyle: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),


     floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      elevation: 3,
),
      inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                ),
              ),
            ),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(
              color: AppColors.primary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
          ),
        ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),

      cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 4,
          ),
        ),
      chipTheme: ChipThemeData(
          backgroundColor: AppColors.background,
          selectedColor: AppColors.successSoft,
          labelStyle: const TextStyle(
            color: AppColors.text,
          ),
        ),

        snackBarTheme: const SnackBarThemeData(
            backgroundColor: AppColors.primaryDark,
            contentTextStyle: TextStyle(
              color: Colors.white,
          ),
        ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titleTextStyle: const TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: AppColors.text,
            fontSize: 16,
          ),
        ),

        dropdownMenuTheme: const DropdownMenuThemeData(
            textStyle: TextStyle(
              color: AppColors.text,
            ),
          ),

          iconTheme: const IconThemeData(
              color: AppColors.primary,
            ),

          checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.all(AppColors.primary),
              ),

              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.all(AppColors.primary),
                trackColor: WidgetStateProperty.all(
                  AppColors.successSoft,
                ),
              ),
        
            dividerTheme: const DividerThemeData(
              color: Color(0xFFE5E7EB),
              thickness: 1,
            ),

          tooltipTheme: const TooltipThemeData(
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              textStyle: TextStyle(
                color: Colors.white,
              ),
            ),

    );
  }
}
