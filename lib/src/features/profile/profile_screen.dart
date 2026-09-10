// Profile Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../auth/auth_provider.dart';
import '../../core/api/api_client.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../shared/models/models.dart';

final profileProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, userId) async {
  final ApiClient client = ref.watch(apiClientProvider);
  return client.getProfile(userId);
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<CPUser?> authState = ref.watch(authStateProvider);
    final CPUser? user = authState.value;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login'),
          ),
        ),
      );
    }

    final AsyncValue<Map<String, dynamic>> profileAsync =
        ref.watch(profileProvider(user.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        data: (profile) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _ProfileHeader(
                user: user,
                profile: profile,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(CPSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ProfileStats(profile: profile),
                  const SizedBox(height: CPSpacing.xl),
                  _ProfileBadges(profile: profile),
                  const SizedBox(height: CPSpacing.xl),
                  _ProfileActions(),
                  const SizedBox(height: CPSpacing.xxxl),
                ]),
              ),
            ),
          ],
        ),
        loading: _ProfileSkeleton.new,
        error: (Object e, _) => _ErrorState(
          error: e.toString(),
          onRetry: () => ref.invalidate(profileProvider),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final CPUser user;
  final Map<String, dynamic> profile;

  const _ProfileHeader({required this.user, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CPSpacing.xl),
      decoration: BoxDecoration(
        color: CPColors.card,
        border: Border(bottom: BorderSide(color: CPColors.line)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: CPColors.bg800,
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? const Icon(Icons.person, size: 50, color: CPColors.muted)
                : null,
          ),
          const SizedBox(height: CPSpacing.lg),
          Text(user.username, style: CPTextStyles.headlineMedium),
          const SizedBox(height: CPSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user.isAdmin ?? false)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CPColors.purple.withOpacity(0.16),
                    border: Border.all(color: CPColors.purple.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(CPRadius.pill),
                  ),
                  child: Text(
                    'Admin',
                    style: CPTextStyles.labelSmall
                        .copyWith(color: CPColors.purple),
                  ),
                ),
              const SizedBox(width: CPSpacing.sm),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CPColors.primary.withOpacity(0.16),
                  border: Border.all(
                    color: CPColors.primary.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(CPRadius.pill),
                ),
                child: Text(
                  'Analyst',
                  style:
                      CPTextStyles.labelSmall.copyWith(color: CPColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: CPSpacing.md),
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: CPTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            )
          else
            Text(
              'No bio yet',
              style: CPTextStyles.bodyMedium.copyWith(color: CPColors.muted),
            ),
          const SizedBox(height: CPSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatColumn(
                label: 'Rank',
                value: '#${profile['rank'] ?? '?'}',
                color: CPColors.gold,
              ),
              const SizedBox(width: CPSpacing.xl),
              _StatColumn(
                label: 'Solves',
                value: '${user.solvedCount ?? 0}',
                color: CPColors.success,
              ),
              const SizedBox(width: CPSpacing.xl),
              _StatColumn(
                label: 'Points',
                value: '${user.rankPoints ?? 0}',
                color: CPColors.primary,
              ),
              const SizedBox(width: CPSpacing.xl),
              _StatColumn(
                label: 'Coins',
                value: '${user.coins ?? 0}',
                color: CPColors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('user', user));
    properties.add(DiagnosticsProperty('profile', profile));
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: CPTextStyles.headlineSmall.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: CPTextStyles.bodySmall),
        ],
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('label', label));
    properties.add(DiagnosticsProperty('value', value));
    properties.add(DiagnosticsProperty('color', color));
  }
}

class _ProfileStats extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _ProfileStats({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CPSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistics', style: CPTextStyles.headlineSmall),
            const SizedBox(height: CPSpacing.lg),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2,
              children: [
                _StatItem(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${profile['daily_streak'] ?? 0} days',
                  color: CPColors.danger,
                ),
                _StatItem(
                  icon: Icons.verified,
                  label: 'Reports Approved',
                  value: '${profile['reports_approved'] ?? 0}',
                  color: CPColors.success,
                ),
                _StatItem(
                  icon: Icons.lock_open,
                  label: 'Hints Unlocked',
                  value: '${profile['hints_unlocked'] ?? 0}',
                  color: CPColors.amber,
                ),
                _StatItem(
                  icon: Icons.visibility,
                  label: 'Profile Views',
                  value: '${profile['profile_views'] ?? 0}',
                  color: CPColors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('profile', profile));
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CPSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(CPRadius.md),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(CPRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: CPSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: CPTextStyles.bodySmall),
              Text(value,
                  style: CPTextStyles.titleMedium.copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('icon', icon));
    properties.add(DiagnosticsProperty('label', label));
    properties.add(DiagnosticsProperty('value', value));
    properties.add(DiagnosticsProperty('color', color));
  }
}

class _ProfileBadges extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _ProfileBadges({required this.profile});

  @override
  Widget build(BuildContext context) {
    final List<String> badges = <String>[];
    if ((profile['solved_count'] ?? 0) >= 1) badges.add('Rookie');
    if ((profile['solved_count'] ?? 0) >= 3) badges.add('Resolver');
    if ((profile['rank_points'] ?? 0) >= 1000) badges.add('Investigator');
    if ((profile['coins'] ?? 0) >= 200) badges.add('Wealthy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badges', style: CPTextStyles.headlineSmall),
        const SizedBox(height: CPSpacing.md),
        Wrap(
          spacing: CPSpacing.sm,
          runSpacing: CPSpacing.sm,
          children: badges
              .map((badge) => Chip(
                    label: Text(badge, style: CPTextStyles.labelSmall),
                    avatar: Icon(_getBadgeIcon(badge),
                        size: 16, color: CPColors.primary),
                    backgroundColor: CPColors.primary.withOpacity(0.12),
                    side: BorderSide(color: CPColors.primary.withOpacity(0.3)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  IconData _getBadgeIcon(String badge) {
    switch (badge) {
      case 'Rookie':
        return Icons.emoji_events;
      case 'Resolver':
        return Icons.military_tech;
      case 'Investigator':
        return Icons.search;
      case 'Wealthy':
        return Icons.monetization_on;
      default:
        return Icons.star;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('profile', profile));
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions', style: CPTextStyles.headlineSmall),
        const SizedBox(height: CPSpacing.md),
        ListTile(
          leading: const Icon(Icons.edit, color: CPColors.text),
          title: Text('Edit Profile', style: CPTextStyles.bodyMedium),
          trailing: const Icon(Icons.chevron_right, color: CPColors.muted),
          onTap: () => context.push('/settings'),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CPRadius.md)),
          tileColor: CPColors.card,
        ),
        const SizedBox(height: CPSpacing.sm),
        ListTile(
          leading: const Icon(Icons.history, color: CPColors.text),
          title: Text('Solve History', style: CPTextStyles.bodyMedium),
          trailing: const Icon(Icons.chevron_right, color: CPColors.muted),
          onTap: () {},
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CPRadius.md)),
          tileColor: CPColors.card,
        ),
        const SizedBox(height: CPSpacing.sm),
        ListTile(
          leading: const Icon(Icons.bookmark, color: CPColors.text),
          title: Text('Bookmarked Challenges', style: CPTextStyles.bodyMedium),
          trailing: const Icon(Icons.chevron_right, color: CPColors.muted),
          onTap: () {},
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CPRadius.md)),
          tileColor: CPColors.card,
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CPColors.bg800,
      highlightColor: CPColors.bg700,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: CPColors.bg800,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 16),
                Container(height: 24, width: 150, color: CPColors.bg800),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    4,
                    (i) => Expanded(
                      child: Container(
                        height: 60,
                        color: CPColors.bg800,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CPSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: CPColors.danger),
            const SizedBox(height: CPSpacing.md),
            Text('Failed to load profile', style: CPTextStyles.headlineSmall),
            const SizedBox(height: CPSpacing.xs),
            Text(
              error,
              style: CPTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: CPSpacing.lg),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('error', error));
    properties.add(DiagnosticsProperty('onRetry', onRetry));
  }
}
