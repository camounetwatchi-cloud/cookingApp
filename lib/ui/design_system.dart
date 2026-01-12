import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

/// Core color tokens aligned with the provided Figma palette.
class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF0088FF);
  static const Color deepBlack = Color(0xFF090909);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0x991A1A1A);
  static const Color background = Color(0xFFF9F5F2);
  static const Color surface = Colors.white;
  static const Color stroke = Color(0x14000000);
  static const Color shadow = Color(0x1A000000);

  // Apple Liquid Mesh Palettes
  static const List<Color> skyMesh = [
    Color(0xFF007AFF), // Blue
    Color(0xFF5AC8FA), // Light Blue
    Color(0xFFAF52DE), // Purple
    Color(0xFFFFFFFF), // White
  ];

  static const List<Color> sunsetMesh = [
    Color(0xFFFF9500), // Orange
    Color(0xFFFF2D55), // Pink/Red
    Color(0xFF5856D6), // Deep Purple
    Color(0xFFFFFFFF),
  ];

  static const List<Color> mintMesh = [
    Color(0xFF34C759), // Green
    Color(0xFF007AFF), // Blue
    Color(0xFF5AC8FA), // Sky
    Color(0xFFFFFFFF),
  ];
}

/// Reusable shadow presets.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> glasses = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: 24,
      offset: Offset(0, 12),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> liquidGlass = [
    BoxShadow(
      color: Color(0x0F000000), // Slightly deeper shadow
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
}

/// Dynamic background with moving organic gradients (Liquid Mesh Effect)
class LiquidBackground extends StatefulWidget {
  const LiquidBackground({
    super.key,
    required this.child,
    this.primaryColor = const Color(0xFFFFFFFF), // White
    this.secondaryColor = const Color(0xFFFFFFFF), // White
    this.accentColor = const Color(0xFFFFFFFF), // White
    this.quaternaryColor = const Color(0xFFFFFFFF), // White
  });

  final Widget child;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color quaternaryColor;

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            // Base background
            Positioned.fill(
              child: Container(color: widget.primaryColor),
            ),
            
            // Moving Liquid Blob 1
            _buildLiquidBlob(
              color: widget.secondaryColor.withValues(alpha: 0.25),
              size: 600,
              offset: Offset(
                -200 + 200 * math.sin(_controller.value * 2 * math.pi),
                -150 + 150 * math.cos(_controller.value * 2 * math.pi),
              ),
              blur: 120,
            ),
            
            // Moving Liquid Blob 2
            _buildLiquidBlob(
              color: widget.accentColor.withValues(alpha: 0.2),
              size: 550,
              offset: Offset(
                MediaQuery.of(context).size.width - 300 + 150 * math.cos(_controller.value * 2 * math.pi + 1),
                MediaQuery.of(context).size.height - 450 + 180 * math.sin(_controller.value * 2 * math.pi + 1),
              ),
              blur: 140,
            ),
            
            // Moving Liquid Blob 3 (Center)
            _buildLiquidBlob(
              color: widget.quaternaryColor.withValues(alpha: 0.15),
              size: 700,
              offset: Offset(
                MediaQuery.of(context).size.width / 2 - 350 + 100 * math.sin(_getRotation(0.5)),
                MediaQuery.of(context).size.height / 2 - 350 + 100 * math.cos(_getRotation(0.5)),
              ),
              blur: 160,
            ),

            // Moving Liquid Blob 4 (Top Right)
            _buildLiquidBlob(
              color: widget.quaternaryColor.withValues(alpha: 0.4),
              size: 400,
              offset: Offset(
                MediaQuery.of(context).size.width - 200 + 150 * math.sin(_getRotation(0.8)),
                50 + 100 * math.cos(_getRotation(0.8)),
              ),
              blur: 160,
            ),

            // Content
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }

  double _getRotation(double offset) {
    return (_controller.value + offset) * 2 * math.pi;
  }

  Widget _buildLiquidBlob({
    required Color color,
    required double size,
    required Offset offset,
    required double blur,
  }) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}

/// Liquid Glass Button - Modern glassmorphism button with advanced shadow effects
class LiquidGlassButton extends StatefulWidget {
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
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleHighlight(bool value) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {

    final decorationColor = widget.isBlue
        ? AppColors.primaryBlue
        : const Color(0xFFF9FBFF);

    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: const ElasticOutCurve(0.9),
      scale: _isPressed ? 0.96 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.height / 2), // Full pill
          boxShadow: AppShadows.liquidGlass,
          color: decorationColor,
          border: Border.all(
            color: widget.isBlue ? Colors.white.withValues(alpha: 0.2) : const Color(0x33FFFFFF),
            width: 0.8,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: InkWell(
            onTap: () {
              if (widget.onPressed != null && !widget.isLoading) {
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            },
            splashColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.transparent,
            onHighlightChanged: _handleHighlight,
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: Container(
              height: widget.height,
              width: widget.width,
              alignment: Alignment.center,
              child: widget.isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.isBlue ? Colors.white : AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class LiquidEntrance extends StatefulWidget {
  const LiquidEntrance({
    super.key,
    required this.child,
    this.offset = const Offset(0, 40),
    this.duration = const Duration(milliseconds: 1000),
    this.delay = Duration.zero,
    this.curve = Curves.elasticOut,
  });

  final Widget child;
  final Offset offset;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  @override
  State<LiquidEntrance> createState() => _LiquidEntranceState();
}

class _LiquidEntranceState extends State<LiquidEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _animation =
      CurvedAnimation(parent: _controller, curve: widget.curve);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final dx = widget.offset.dx * (1 - value);
        final dy = widget.offset.dy * (1 - value);
        // Elastic scale effect
        final scale = 0.85 + (0.15 * value);
        
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Simple glassmorphism container for the Apple-like "liquid glass" effect.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 28,
    this.blur = 20,
    this.backgroundOpacity = 0.45,
    this.strokeOpacity = 0.25,
    this.shadows,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final double blur;
  final double backgroundOpacity;
  final double strokeOpacity;
  final List<BoxShadow>? shadows;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? AppShadows.liquidGlass,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withValues(alpha: backgroundOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: strokeOpacity),
                width: 0.8, // Thinner, crisper border
              ),
            ),
            child: child,
          ),
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
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.borderRadius = 28,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final blurSigma = isSelected ? 35.0 : 20.0;
        
        final boxShadows = isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.35),
                  blurRadius: 30,
                  spreadRadius: -4,
                  offset: const Offset(0, 16),
                ),
              ]
            : AppShadows.liquidGlass;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()..scaleByDouble(isSelected ? 1.02 : 1.0, isSelected ? 1.02 : 1.0, 1.0, 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: boxShadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurSigma,
                sigmaY: blurSigma,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : Colors.white.withValues(alpha: 0.18), // Slightly more visible
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.white.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap();
                    },
                    splashColor: Colors.white.withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Padding(
                      padding: padding,
                      child: Center(child: child),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A premium Pill Search Bar inspired by Image 1
class PillSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const PillSearchBar({
    super.key,
    this.hintText = "Rechercher...",
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 40,
      backgroundOpacity: 0.2, // Very subtle glass
      blur: 30, // High blur for depth
      child: TextField(
        onChanged: onChanged,
        onTap: onTap,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.deepBlack,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.deepBlack.withValues(alpha: 0.35),
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.deepBlack.withValues(alpha: 0.4),
            size: 22,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}

/// Premium Floating Dock inspired by Image 2
class FloatingPillDock extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  final List<DockItem> items;

  const FloatingPillDock({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          borderRadius: 40,
          backgroundOpacity: 0.6,
          blur: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTabSelected(index);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Icon(
                      items[index].icon,
                      color: isSelected ? Colors.white : AppColors.deepBlack.withValues(alpha: 0.45),
                      size: 24,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class DockItem {
  final IconData icon;
  final String label;

  const DockItem({required this.icon, required this.label});
}

/// A premium radar-like scanning animation for the fridge analysis phase.
class RadarScanner extends StatefulWidget {
  final double size;
  final Color color;

  const RadarScanner({
    super.key,
    this.size = 180,
    this.color = AppColors.primaryBlue,
  });

  @override
  State<RadarScanner> createState() => _RadarScannerState();
}

class _RadarScannerState extends State<RadarScanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: widget.size * 0.4,
            height: widget.size * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          
          // Rings
          ...List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final progress = (_controller.value + (index / 3)) % 1.0;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final scale = 0.2 + (0.8 * progress);

                return Transform(
                  transform: Matrix4.identity()..scaleByDouble(scale, scale, 1.0, 1.0),
                  child: Opacity(
                    opacity: opacity * 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.color,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Rotating Scanner Beam
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      center: Alignment.center,
                      startAngle: 0.0,
                      endAngle: math.pi / 2,
                      colors: [
                        widget.color.withValues(alpha: 0.0),
                        widget.color.withValues(alpha: 0.5),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          // Central Pulse
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final pulse = 0.9 + 0.1 * math.sin(_controller.value * 2 * math.pi * 2);
              return Transform.scale(
                scale: pulse,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}


/// Floating navigation bar for onboarding screens with glass buttons.
class OnboardingNavBar extends StatelessWidget {
  const OnboardingNavBar({
    super.key,
    required this.onNext,
    this.onBack,
    this.nextLabel = 'Continuer',
    this.nextIcon = Icons.play_arrow_rounded,
  });

  final VoidCallback onNext;
  final VoidCallback? onBack;
  final String nextLabel;
  final IconData nextIcon;

  @override
  Widget build(BuildContext context) {
    final hasBack = onBack != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (hasBack) _GlassSecondaryButton(onPressed: onBack!),
            if (hasBack) const SizedBox(width: 16),
            Expanded(
              child: Align(
                alignment: hasBack ? Alignment.centerRight : Alignment.center,
                child: _GlassPrimaryButton(
                  label: nextLabel,
                  icon: nextIcon,
                  onPressed: onNext,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassPrimaryButton extends StatelessWidget {
  const _GlassPrimaryButton({
    required this.onPressed,
    required this.label,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 32,
      backgroundOpacity: 1.0,
      backgroundColor: AppColors.deepBlack,
      strokeOpacity: 0.1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onPressed,
          splashColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSecondaryButton extends StatelessWidget {
  const _GlassSecondaryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      backgroundOpacity: 0.28,
      strokeOpacity: 0.22,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          splashColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 14, color: AppColors.deepBlack),
                const SizedBox(width: 8),
                Text(
                  'RETOUR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deepBlack,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: GlassPageTransitionsBuilder(),
          TargetPlatform.iOS: GlassPageTransitionsBuilder(),
          TargetPlatform.macOS: GlassPageTransitionsBuilder(),
          TargetPlatform.windows: GlassPageTransitionsBuilder(),
          TargetPlatform.linux: GlassPageTransitionsBuilder(),
          TargetPlatform.fuchsia: GlassPageTransitionsBuilder(),
        },
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.deepBlack,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme)
          .apply(
        bodyColor: AppColors.deepBlack,
        displayColor: AppColors.deepBlack,
      ).copyWith(
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: -1.5, fontSize: 34),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: -1, fontSize: 24),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.35),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.deepBlack,
        iconTheme: const IconThemeData(color: AppColors.deepBlack),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.deepBlack,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.4),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.05),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.8),
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
          side: BorderSide(color: AppColors.textPrimary.withValues(alpha: 0.18)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface.withValues(alpha: 0.72),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface.withValues(alpha: 0.72),
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

class GlassPageTransitionsBuilder extends PageTransitionsBuilder {
  const GlassPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == Navigator.defaultRouteName) return child;

    final primary = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeIn,
    );
    final secondaryCurve = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(primary),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.08),
          end: Offset.zero,
        ).animate(primary),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(primary),
          child: DecoratedBoxTransition(
            position: DecorationPosition.background,
            decoration: TweenSequence([
              TweenSequenceItem(
                tween: DecorationTween(
                  begin: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  end: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
                weight: 1,
              ),
            ]).animate(secondaryCurve),
            child: child,
          ),
        ),
      ),
    );
  }
}
