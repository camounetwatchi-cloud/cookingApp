import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Core color tokens aligned with the provided Figma palette.
class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF0088FF);
  static const Color textPrimary = Color(0xFF262626);
  static const Color textMuted = Color(0x99262626); // 60% alpha
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Colors.white;
  static const Color stroke = Color(0x14000000); // 8% black
  static const Color shadow = Color(0x14000000); // 8% black for soft shadow
}

/// Reusable shadow presets.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> glass = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 24,
      offset: Offset(0, 12),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> liquidGlass = [
    BoxShadow(
      color: Color(0x0A000000), // ~6% black - reduced
      blurRadius: 12,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
}

/// Liquid Glass Button - Modern glassmorphism button with advanced shadow effects
class LiquidGlassButton extends StatelessWidget {
  const LiquidGlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.height = 56,
    this.width,
    this.isBlue = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final double height;
  final double? width;
  final bool isBlue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        boxShadow: AppShadows.liquidGlass,
        gradient: isBlue
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withOpacity(0.9),
                  AppColors.primaryBlue.withOpacity(0.8),
                ],
              )
            : const RadialGradient(
                center: Alignment(-1.0, -1.0), // top-left corner
                radius: 1.4,
                colors: [
                  Color(0xFFF2F2F2), // subtle gray at top-left corner
                  Color(0xFFF8F8F8), // light transition
                  Color(0xFFFFFFFF), // pure white
                  Color(0xFFFFFFFF), // pure white majority
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
        border: Border.all(
          color: const Color(0x52FFFFFF), // rgba(255, 255, 255, 0.32)
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(34),
        child: InkWell(
            onTap: isLoading ? null : onPressed,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          borderRadius: BorderRadius.circular(34),
          child: Container(
            height: height,
            width: width,
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isBlue ? Colors.white : AppColors.primaryBlue,
                      ),
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

/// Simple glassmorphism container for the Apple-like "liquid glass" effect.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.blur = 18,
    this.backgroundOpacity = 0.35,
    this.strokeOpacity = 0.18,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blur;
  final double backgroundOpacity;
  final double strokeOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(backgroundOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.surface.withOpacity(strokeOpacity),
            ),
            boxShadow: AppShadows.glass,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Selectable Glass Button - Glassmorphism button for onboarding selections
class SelectableGlassButton extends StatelessWidget {
  const SelectableGlassButton({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    this.borderRadius = 22,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppShadows.liquidGlass,
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryBlue.withOpacity(0.9),
                  AppColors.primaryBlue.withOpacity(0.8),
                ],
              )
            : const RadialGradient(
                center: Alignment(-1.0, -1.0), // top-left corner
                radius: 2.5,
                colors: [
                  Color(0xFFF2F2F2), // subtle gray at top-left corner
                  Color(0xFFF8F8F8), // light transition
                  Color(0xFFFFFFFF), // pure white
                  Color(0xFFFFFFFF), // pure white majority
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
        border: Border.all(
          color: const Color(0x52FFFFFF), // rgba(255, 255, 255, 0.32)
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Centralized light theme using Inter and the Apple-like palette.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        background: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface.withOpacity(0.72),
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadow,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface.withOpacity(0.72),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: AppColors.shadow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface.withOpacity(0.8),
        hintStyle: TextStyle(color: AppColors.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.stroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.textPrimary.withOpacity(0.18)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface.withOpacity(0.72),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.stroke),
        ),
      ),
    );

    return base;
  }
}

