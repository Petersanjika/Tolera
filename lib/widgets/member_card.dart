import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/member.dart';
import '../core/utils/formatters.dart';
import '../theme/app_colors.dart';

/// Animated member card with avatar, name, contact, and payment status badge.
class MemberCard extends StatelessWidget {
  final Member member;
  final bool hasPaid;
  final VoidCallback? onTap;
  final int animationIndex;

  const MemberCard({
    super.key,
    required this.member,
    this.hasPaid = false,
    this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.white;

    return Animate(
      delay: Duration(milliseconds: 60 * animationIndex),
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 400)),
        SlideEffect(
          begin: Offset(0.05, 0),
          end: Offset.zero,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        ),
      ],
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${member.houseNumber}  •  ${member.village}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.maskPhone(member.phone),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Payment status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildPaymentBadge(),
                    const SizedBox(height: 6),
                    _buildStatusBadge(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = AppFormatters.initials(member.fullName);
    final colors = _avatarColors(member.id ?? 0);

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: hasPaid ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        hasPaid ? 'Paid' : 'Unpaid',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: hasPaid ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: member.isActive
            ? AppColors.teal.withOpacity(0.12)
            : AppColors.textHint.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        member.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: member.isActive ? AppColors.teal : AppColors.textHint,
        ),
      ),
    );
  }

  List<Color> _avatarColors(int id) {
    final palettes = [
      [AppColors.deepBlue, AppColors.teal],
      [AppColors.teal, AppColors.green],
      [AppColors.aqua, AppColors.deepBlue],
      [AppColors.green, AppColors.mint],
      [AppColors.turquoise, AppColors.deepBlue],
      [AppColors.mediumBlue, AppColors.aqua],
    ];
    return palettes[id % palettes.length];
  }
}
