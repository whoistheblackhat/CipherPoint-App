// Dashboard Screen - Matches website dashboard exactly

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../core/api/api_client.dart';
import '../auth/auth_provider.dart';
import '../../shared/models/models.dart';

final dashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final challengesResult = await client.getChallenges(limit: 6);
  final leaderboardResult = await client.getLeaderboard(limit: 5);
  final intelResult = await client.getIntelArticles(limit: 4);
  return {
    'challenges': challengesResult.map((e) => CPChallenge.fromJson(e)).toList(),
    'leaderboard': (leaderboardResult['users'] as List)
        .map((e) => CPLeaderboardEntry.fromJson(e))
        .toList(),
    'intel': intelResult.map((e) => CPIntelArticle.fromJson(e)).toList(),
  };
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _DashboardAppBar(user: user),
          SliverToBoxAdapter(
            child: dataAsync.when(
              data: (data) => _DashboardContent(
                challenges: data['challenges'] as List<CPChallenge>,
                leaderboard: data['leaderboard'] as List<CPLeaderboardEntry>,
                intel: data['intel'] as List<CPIntelArticle>,
              ),
              loading: () => _DashboardSkeleton(),
              error: (e, _) => _DashboardError(error: e.toString()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/challenges'),
        icon: const Icon(Icons.add),
        label: const Text('New Challenge'),
      ),
    );
  }
}

class _DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final CPUser? user;

  const _DashboardAppBar({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: 72,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CPColors.bg800,
                borderRadius: BorderRadius.circular(CPRadius.md),
                border: Border.all(color: CPColors.lineStrong),
              ),
              child: const Icon(Icons.person, color: CPColors.text, size: 20),
            ),
            const SizedBox(width: 10),
            Text('CipherPoint', style: CPTextStyles.headlineSmall),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.push('/challenges'),
          tooltip: 'Search challenges',
        ),
        IconButton(
          icon: const Icon(Icons.book_outlined),
          onPressed: () => context.push('/intel'),
          tooltip: 'Intel Vault',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => context.push('/notifications'),
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: CPColors.bg800,
            backgroundImage:
                user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
            child: user?.avatarUrl == null
                ? const Icon(Icons.person, size: 18, color: CPColors.muted)
                : null,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _DashboardContent extends StatelessWidget {
  final List<CPChallenge> challenges;
  final List<CPLeaderboardEntry> leaderboard;
  final List<CPIntelArticle> intel;

  const _DashboardContent({
    required this.challenges,
    required this.leaderboard,
    required this.intel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CPSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Recent Challenges',
            action: TextButton(
              onPressed: () => context.push('/challenges'),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: CPSpacing.md),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: challenges.length,
              separatorBuilder: (_, __) => const SizedBox(width: CPSpacing.md),
              itemBuilder: (context, index) {
                final c = challenges[index];
                return _ChallengeCard(
                  challenge: c,
                  onTap: () => context.push('/challenges/${c.id}'),
                );
              },
            ),
          ),
          const SizedBox(height: CPSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _SectionCard(
                  title: 'Top Analysts',
                  action: TextButton(
                    onPressed: () => context.push('/leaderboard'),
                    child: const Text('View all'),
                  ),
                  child: Column(
                    children: leaderboard.asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final l = entry.value;
                      return _LeaderboardRow(
                        rank: rank,
                        username: l.username,
                        rankPoints: l.rankPoints ?? 0,
                        solvedCount: l.solvedCount ?? 0,
                        isCurrentUser: l.isCurrentUser ?? false,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: CPSpacing.lg),
              Expanded(
                flex: 1,
                child: _SectionCard(
                  title: 'Intel Vault',
                  action: TextButton(
                    onPressed: () => context.push('/intel'),
                    child: const Text('View all'),
                  ),
                  child: Column(
                    children: intel
                        .map((article) => _IntelRow(
                              article: article,
                              onTap: () => context.push('/intel/${article.id}'),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget action;

  const _SectionHeader({required this.title, required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: CPTextStyles.headlineMedium),
        action,
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget action;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.action,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CPSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: title, action: action),
            const SizedBox(height: CPSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final CPChallenge challenge;
  final VoidCallback onTap;

  const _ChallengeCard({required this.challenge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CPRadius.lg),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: CPColors.card,
          borderRadius: BorderRadius.circular(CPRadius.lg),
          border: Border.all(color: CPColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (challenge.telegramFileId != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(CPRadius.lg)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    'https://cipherpoint.linkpc.net/api/media/${challenge.telegramFileId}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: CPColors.bg800,
                      child: const Center(
                          child: Icon(Icons.image, color: CPColors.muted)),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(CPSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: challenge.categoryColor.withOpacity(0.12),
                          border: Border.all(
                              color: challenge.categoryColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(CPRadius.pill),
                        ),
                        child: Text(
                          'lab/${challenge.category}',
                          style: CPTextStyles.labelSmall
                              .copyWith(color: challenge.categoryColor),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: challenge.difficultyColor.withOpacity(0.12),
                          border: Border.all(
                              color:
                                  challenge.difficultyColor.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(CPRadius.pill),
                        ),
                        child: Text(
                          challenge.difficultyLabel,
                          style: CPTextStyles.labelSmall
                              .copyWith(color: challenge.difficultyColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: CPSpacing.sm),
                  Text(
                    challenge.title,
                    style: CPTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: CPSpacing.xs),
                  Row(
                    children: [
                      Icon(Icons.flag, size: 14, color: CPColors.muted),
                      const SizedBox(width: 4),
                      Text(
                        '${challenge.pointsReward ?? 0} pts',
                        style: CPTextStyles.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      if (challenge.solvedCount != null &&
                          challenge.solvedCount! > 0) ...[
                        Icon(Icons.check_circle,
                            size: 14, color: CPColors.success),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.solvedCount} solves',
                          style: CPTextStyles.bodySmall
                              .copyWith(color: CPColors.success),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String username;
  final int rankPoints;
  final int solvedCount;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.rank,
    required this.username,
    required this.rankPoints,
    required this.solvedCount,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? CPColors.primary.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(CPRadius.md),
        border: isCurrentUser
            ? Border.all(color: CPColors.primary.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '#$rank',
              style: CPTextStyles.labelMedium.copyWith(
                color: rank <= 3 ? CPColors.gold : CPColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: CPSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(username, style: CPTextStyles.titleSmall),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: CPColors.primary.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(CPRadius.pill),
                        ),
                        child: Text(
                          'You',
                          style: CPTextStyles.labelSmall
                              .copyWith(color: CPColors.primary),
                        ),
                      ),
                    ],
                  ],
                ),
                Text('$solvedCount solves · $rankPoints pts',
                    style: CPTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IntelRow extends StatelessWidget {
  final CPIntelArticle article;
  final VoidCallback onTap;

  const _IntelRow({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CPRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CPColors.teal.withOpacity(0.12),
                border: Border.all(color: CPColors.teal.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(CPRadius.pill),
              ),
              child: Text(
                'lab/${article.category}',
                style: CPTextStyles.labelSmall.copyWith(color: CPColors.teal),
              ),
            ),
            const SizedBox(width: CPSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: CPTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.summary != null)
                    Text(
                      article.summary!,
                      style: CPTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: CPColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CPSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Recent Challenges', action: const SizedBox()),
          const SizedBox(height: CPSpacing.md),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: CPSpacing.md),
              itemBuilder: (_, __) => Container(
                width: 280,
                decoration: BoxDecoration(
                  color: CPColors.card,
                  borderRadius: BorderRadius.circular(CPRadius.lg),
                  border: Border.all(color: CPColors.line),
                ),
                child: Shimmer.fromColors(
                  baseColor: CPColors.bg800,
                  highlightColor: CPColors.bg700,
                  child: Container(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String error;

  const _DashboardError({required this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CPSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: CPColors.danger),
            const SizedBox(height: CPSpacing.md),
            Text('Failed to load dashboard', style: CPTextStyles.headlineSmall),
            const SizedBox(height: CPSpacing.xs),
            Text(error,
                style: CPTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: CPSpacing.lg),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
