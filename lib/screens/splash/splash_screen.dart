import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../auth/role_selection_screen.dart';

/// Animated splash screen with Tolera branding and water theme
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to login after animation completes
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.oceanGradient),
        child: Stack(
          children: [
            // Background bubbles
            ..._buildBubbles(),
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 20),
                  // App name
                  const Text(
                    'TOLERA',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 700.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Transparent Water Management',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 700.ms),
                  const SizedBox(height: 60),
                  // Loading indicator
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: AppColors.aquaLight,
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1400.ms, duration: 500.ms),
                ],
              ),
            ),
            // Bottom tagline
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'Community • Accountability • Trust',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.5),
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ).animate().fadeIn(delay: 1600.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.aqua.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.water_drop_rounded,
        color: AppColors.white,
        size: 56,
      ),
    )
        .animate()
        .fadeIn(duration: 700.ms)
        .scaleXY(begin: 0.6, end: 1.0, curve: Curves.elasticOut)
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.04,
          duration: 2000.ms,
          curve: Curves.easeInOut,
          delay: 1200.ms,
        );
  }

  List<Widget> _buildBubbles() {
    final bubbles = [
      _BubbleData(top: 80, left: 40, size: 80, delay: 200),
      _BubbleData(top: 200, right: 30, size: 50, delay: 400),
      _BubbleData(bottom: 200, left: 20, size: 60, delay: 600),
      _BubbleData(bottom: 100, right: 50, size: 90, delay: 300),
      _BubbleData(top: 350, left: 80, size: 35, delay: 700),
      _BubbleData(top: 100, right: 100, size: 45, delay: 500),
    ];

    return bubbles
        .map(
          (b) => Positioned(
            top: b.top,
            bottom: b.bottom,
            left: b.left,
            right: b.right,
            child: Container(
              width: b.size,
              height: b.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.5,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: b.delay), duration: 800.ms),
          ),
        )
        .toList();
  }
}

class _BubbleData {
  final double? top, bottom, left, right;
  final double size;
  final int delay;

  _BubbleData({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.delay,
  });
}
