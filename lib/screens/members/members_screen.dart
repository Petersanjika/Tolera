import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../providers/members_provider.dart';
import '../../providers/contributions_provider.dart';
import '../../widgets/member_card.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/empty_state_widget.dart';
import 'member_form_screen.dart';
import 'member_profile_screen.dart';

/// Members screen – lists all registered members with search and filter.
class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All'; // 'All' | 'Paid' | 'Unpaid' | 'Active' | 'Inactive'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paidIds = ref.watch(paidMemberIdsProvider).valueOrNull ?? [];

    return Scaffold(
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _buildHeader(context),
          // ── Search ──────────────────────────────────────────────────────
          _buildSearchBar(context, isDark),
          // ── Filter Chips ─────────────────────────────────────────────────
          _buildFilterChips(context),
          // ── List ─────────────────────────────────────────────────────────
          Expanded(child: _buildMemberList(context, paidIds)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: _navigateToAddMember,
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text(
          'Add Member',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ).animate().scale(delay: 600.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final memberCount = ref.watch(memberCountProvider);
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(
            children: [
              const Icon(Icons.people_rounded,
                  color: AppColors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Members',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    memberCount.when(
                      data: (count) => Text(
                        '$count active members',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.75),
                          fontSize: 13,
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.offWhite,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          ref.read(memberSearchQueryProvider.notifier).state = v;
          setState(() {});
        },
        decoration: InputDecoration(
          hintText: 'Search by name, phone, or house number…',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.teal),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(memberSearchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = ['All', 'Paid', 'Unpaid', 'Active', 'Inactive'];
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.offWhite,
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final isSelected = _filter == f;
          return FilterChip(
            label: Text(f),
            selected: isSelected,
            onSelected: (_) => setState(() => _filter = f),
            selectedColor: AppColors.teal.withOpacity(0.15),
            checkmarkColor: AppColors.teal,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.teal : AppColors.textSecondary,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.teal
                  : AppColors.divider,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberList(BuildContext context, List<int> paidIds) {
    final membersAsync = ref.watch(filteredMembersProvider);

    return membersAsync.when(
      data: (members) {
        // Apply filter
        var filtered = members;
        if (_filter == 'Paid') {
          filtered = members.where((m) => paidIds.contains(m.id)).toList();
        } else if (_filter == 'Unpaid') {
          filtered = members.where((m) => !paidIds.contains(m.id)).toList();
        } else if (_filter == 'Active') {
          filtered = members.where((m) => m.isActive).toList();
        } else if (_filter == 'Inactive') {
          filtered = members.where((m) => !m.isActive).toList();
        }

        if (filtered.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.people_outline_rounded,
            title: 'No Members Found',
            subtitle: _searchController.text.isNotEmpty
                ? 'Try a different search term.'
                : 'Add your first community member to get started.',
            actionLabel: 'Add Member',
            onAction: _navigateToAddMember,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final member = filtered[index];
            return MemberCard(
              member: member,
              hasPaid: paidIds.contains(member.id),
              animationIndex: index,
              onTap: () => _navigateToProfile(member),
            );
          },
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.all(16),
        child: LoadingSkeleton(itemCount: 6),
      ),
      error: (err, _) => Center(
        child: Text('Error loading members: $err'),
      ),
    );
  }

  void _navigateToAddMember() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MemberFormScreen()),
    );
    if (result == true) {
      ref.invalidate(membersProvider);
      ref.invalidate(memberCountProvider);
      ref.invalidate(filteredMembersProvider);
      ref.invalidate(activeMembersProvider);
    }
  }

  void _navigateToProfile(dynamic member) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MemberProfileScreen(memberId: member.id!),
      ),
    );
    if (result == true) {
      ref.invalidate(membersProvider);
      ref.invalidate(filteredMembersProvider);
    }
  }
}
