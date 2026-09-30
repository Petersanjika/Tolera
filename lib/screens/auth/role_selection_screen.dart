import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../models/app_user.dart';
import 'user_selection_screen.dart';

/// Step 1 of the login flow: Select your role.
/// Shows animated gradient cards for each of the 5 roles.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  // Role card configuration: role, gradient, icon, delay
  static const _roles = [
    _RoleConfig(
      role: UserRole.chairperson,
      icon: Icons.verified_user_rounded,
      gradientColors: [Color(0xFFFF8F00), Color(0xFFE65100)],
    ),
    _RoleConfig(
      role: UserRole.treasurer,
      icon: Icons.account_balance_wallet_rounded,
      gradientColors: [Color(0xFF2E7D32), Color(0xFF00695C)],
    ),
    _RoleConfig(
      role: UserRole.secretary,
      icon: Icons.assignment_ind_rounded,
      gradientColors: [Color(0xFF6A1B9A), Color(0xFF283593)],
    ),
    _RoleConfig(
      role: UserRole.collector,
      icon: Icons.payments_rounded,
      gradientColors: [Color(0xFF0D47A1), Color(0xFF00838F)],
    ),
    _RoleConfig(
      role: UserRole.member,
      icon: Icons.person_rounded,
      gradientColors: [Color(0xFF00838F), Color(0xFF26A69A)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.oceanGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              _buildHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.separated(
                    itemCount: _roles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _RoleCard(
                        config: _roles[index],
                        delay: index * 100,
                        onTap: () => _navigate(context, _roles[index].role),
                      );
                    },
                  ),
                ),
              ),
              _buildDemoHint(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.water_drop_rounded, color: AppColors.aquaLight, size: 48)
            .animate()
            .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 12),
        const Text(
          'TOLERA',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
          ),
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 4),
        Text(
          'Select your role to continue',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.75),
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDemoHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          'Demo PINs — Chairperson: 1111 · Treasurer: 2222 · Secretary: 3333 · Collector: 4444 · Member: 5555',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.65),
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => UserSelectionScreen(role: role),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

// ── Role Card ─────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  final _RoleConfig config;
  final int delay;
  final VoidCallback onTap;

  const _RoleCard({
    required this.config,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: config.gradientColors,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: config.gradientColors.last.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(config.icon, color: AppColors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.role.displayName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        config.role.description,
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.white.withOpacity(0.6),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: 0.3, end: 0, delay: Duration(milliseconds: delay), duration: 400.ms, curve: Curves.easeOut);
  }
}

// ── Config ────────────────────────────────────────────────────────────────────

class _RoleConfig {
  final UserRole role;
  final IconData icon;
  final List<Color> gradientColors;

  const _RoleConfig({
    required this.role,
    required this.icon,
    required this.gradientColors,
  });
}
