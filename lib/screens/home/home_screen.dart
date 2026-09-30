import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers/providers.dart';
import '../auth/role_selection_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../members/members_screen.dart';
import '../contributions/contributions_screen.dart';
import '../expenses/expenses_screen.dart';
import '../meetings/meetings_screen.dart';
import '../profile/profile_screen.dart';

/// Main home screen with role-based bottom navigation.
/// Each role sees a different set of tabs as defined in the blueprint.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  /// Tab configuration per role — aligned with blueprint.
  List<_TabConfig> _buildTabs(UserRole? role) {
    switch (role) {
      case UserRole.collector:
        return const [
          _TabConfig(screen: DashboardScreen(), icon: Icons.dashboard_rounded, outlineIcon: Icons.dashboard_outlined, label: 'Dashboard'),
          _TabConfig(screen: MembersScreen(), icon: Icons.people_rounded, outlineIcon: Icons.people_outline_rounded, label: 'Members'),
          _TabConfig(screen: ContributionsScreen(), icon: Icons.payments_rounded, outlineIcon: Icons.payments_outlined, label: 'Payments'),
          _TabConfig(screen: ProfileScreen(), icon: Icons.person_rounded, outlineIcon: Icons.person_outline_rounded, label: 'Profile'),
        ];
      case UserRole.treasurer:
        return const [
          _TabConfig(screen: DashboardScreen(), icon: Icons.dashboard_rounded, outlineIcon: Icons.dashboard_outlined, label: 'Dashboard'),
          _TabConfig(screen: ContributionsScreen(), icon: Icons.payments_rounded, outlineIcon: Icons.payments_outlined, label: 'Payments'),
          _TabConfig(screen: ExpensesScreen(), icon: Icons.receipt_long_rounded, outlineIcon: Icons.receipt_long_outlined, label: 'Expenses'),
          _TabConfig(screen: ProfileScreen(), icon: Icons.person_rounded, outlineIcon: Icons.person_outline_rounded, label: 'Profile'),
        ];
      case UserRole.secretary:
        return const [
          _TabConfig(screen: DashboardScreen(), icon: Icons.dashboard_rounded, outlineIcon: Icons.dashboard_outlined, label: 'Dashboard'),
          _TabConfig(screen: MembersScreen(), icon: Icons.people_rounded, outlineIcon: Icons.people_outline_rounded, label: 'Members'),
          _TabConfig(screen: MeetingsScreen(), icon: Icons.groups_rounded, outlineIcon: Icons.groups_outlined, label: 'Meetings'),
          _TabConfig(screen: ProfileScreen(), icon: Icons.person_rounded, outlineIcon: Icons.person_outline_rounded, label: 'Profile'),
        ];
      case UserRole.member:
        return const [
          _TabConfig(screen: DashboardScreen(), icon: Icons.dashboard_rounded, outlineIcon: Icons.dashboard_outlined, label: 'Home'),
          _TabConfig(screen: ContributionsScreen(), icon: Icons.payments_rounded, outlineIcon: Icons.payments_outlined, label: 'My Payments'),
          _TabConfig(screen: MeetingsScreen(), icon: Icons.groups_rounded, outlineIcon: Icons.groups_outlined, label: 'Meetings'),
          _TabConfig(screen: ProfileScreen(), icon: Icons.person_rounded, outlineIcon: Icons.person_outline_rounded, label: 'Profile'),
        ];
      case UserRole.chairperson:
      default:
        return const [
          _TabConfig(screen: DashboardScreen(), icon: Icons.dashboard_rounded, outlineIcon: Icons.dashboard_outlined, label: 'Dashboard'),
          _TabConfig(screen: MembersScreen(), icon: Icons.people_rounded, outlineIcon: Icons.people_outline_rounded, label: 'Members'),
          _TabConfig(screen: ContributionsScreen(), icon: Icons.payments_rounded, outlineIcon: Icons.payments_outlined, label: 'Payments'),
          _TabConfig(screen: ExpensesScreen(), icon: Icons.receipt_long_rounded, outlineIcon: Icons.receipt_long_outlined, label: 'Expenses'),
          _TabConfig(screen: MeetingsScreen(), icon: Icons.groups_rounded, outlineIcon: Icons.groups_outlined, label: 'Meetings'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tabs = _buildTabs(user?.role);
    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: _BottomBar(
        tabs: tabs,
        currentIndex: safeIndex,
        user: user,
        onTabTap: (i) => setState(() => _currentIndex = i),
        onLogout: () => _confirmLogout(context),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final user = ref.read(currentUserProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LogoutSheet(
        userName: user?.name ?? '',
        roleName: user?.role.displayName ?? '',
        onConfirm: () {
          Navigator.of(context).pop();
          ref.read(currentUserProvider.notifier).state = null;
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const RoleSelectionScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
            (route) => false,
          );
        },
      ),
    );
  }

}

// ── Bottom Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final List<_TabConfig> tabs;
  final int currentIndex;
  final AppUser? user;
  final ValueChanged<int> onTabTap;
  final VoidCallback onLogout;

  const _BottomBar({
    required this.tabs,
    required this.currentIndex,
    required this.user,
    required this.onTabTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepBlue, Color(0xFF00607A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              // Tab items
              ...List.generate(tabs.length, (i) => _NavItem(
                index: i,
                currentIndex: currentIndex,
                icon: tabs[i].outlineIcon,
                activeIcon: tabs[i].icon,
                label: tabs[i].label,
                onTap: () => onTabTap(i),
              )),
              // Divider
              Container(
                width: 1,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: Colors.white.withOpacity(0.2),
              ),
              // Logout button
              _LogoutButton(
                userName: user?.name.split(' ').first ?? '',
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logout Button in Bar ──────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final String userName;
  final VoidCallback onTap;

  const _LogoutButton({required this.userName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Switch',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logout Bottom Sheet ───────────────────────────────────────────────────────

class _LogoutSheet extends StatelessWidget {
  final String userName;
  final String roleName;
  final VoidCallback onConfirm;

  const _LogoutSheet({
    required this.userName,
    required this.roleName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepBlue, AppColors.turquoise],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.swap_horiz_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              'Switch Role?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Logged in as $userName ($roleName).\nReturn to role selection screen?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: AppColors.divider),
                    ),
                    child: const Text('Stay',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.deepBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Switch Role',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Tab Config ────────────────────────────────────────────────────────────────

class _TabConfig {
  final Widget screen;
  final IconData icon;
  final IconData outlineIcon;
  final String label;

  const _TabConfig({
    required this.screen,
    required this.icon,
    required this.outlineIcon,
    required this.label,
  });
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    // Bar is always dark blue, so icons/text are always white-based
    final activeColor = AppColors.aquaLight;
    const inactiveColor = Color(0x99FFFFFF); // white 60%

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
