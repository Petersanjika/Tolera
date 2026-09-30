import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Water wave animated header widget used on the Dashboard.
/// Combines a gradient container with a subtle wave overlay.
class WaterWaveHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const WaterWaveHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
      ),
      child: Stack(
        children: [
          // Decorative bubbles
          _Bubble(top: 20, right: 30, size: 60, opacity: 0.08),
          _Bubble(top: 60, right: 80, size: 40, opacity: 0.06),
          _Bubble(bottom: 10, left: 20, size: 50, opacity: 0.06),
          _Bubble(top: 10, left: 100, size: 30, opacity: 0.05),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -0.1, end: 0),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 150.ms, duration: 500.ms),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final double opacity;

  const _Bubble({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(opacity),
            width: 2,
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.15,
            duration: Duration(milliseconds: 2000 + (size * 20).toInt()),
            curve: Curves.easeInOut,
          ),
    );
  }
}

/// Gradient app bar decoration used as a sliver
class GradientSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final double expandedHeight;
  final bool pinned;

  const GradientSliverAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.expandedHeight = 120,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
      ),
      actions: actions,
      backgroundColor: AppColors.deepBlue,
      foregroundColor: AppColors.white,
    );
  }
}
