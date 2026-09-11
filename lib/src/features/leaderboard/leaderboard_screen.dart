// Leaderboard Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/models.dart';

final leaderboardProvider = FutureProvider<CPLeaderboardResponse>((ref) async {
  final client = ref.watch(apiClientProvider);
  await client.init();
  // Backend returns a flat list, not a {users, current_user} object
  final result = await client.getLeaderboard(limit: 100);
  final users = result.map((e) => CPLeaderboardEntry.fromJson(e)).toList();
  return CPLeaderboardResponse(users: users, currentUser: null);
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Analysts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(leaderboardProvider),
          ),
        ],
      ),
      body: dataAsync.when(
        data: (data) => CustomScrollView(
          slivers: [
            if (data.currentUser != null)
              SliverToBoxAdapter(
                child: _CurrentUserCard(entry: data.currentUser!),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(CPSpacing.lg),
              sliver: SliverList.separated(
                itemCount: data.users.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: CPSpacing.sm),
                itemBuilder: (context, index) {
                  final entry = data.users[index];
                  final isCurrentUser =
                      data.currentUser?.userId == entry.userId;
                  return _LeaderboardTile(
                    rank: index + 1,
                    entry: entry,
                    isCurrentUser: isCurrentUser,
                  );
                },
              ),
            ),
          ],
        ),
        loading: () => _LeaderboardSkeleton(),
        error: (e, _) => _ErrorState(
          error: e.toString(),
          onRetry: () => ref.invalidate(leaderboardProvider),
        ),
      ),
    );
  }
}

class _CurrentUserCard extends StatelessWidget {
  final CPLeaderboardEntry entry;

  const _CurrentUserCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(CPSpacing.lg),
      padding: const EdgeInsets.all(CPSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CPColors.primary.withOpacity(0.16),
            CPColors.teal.withOpacity(0.16)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(CPRadius.xl),
        border: Border.all(color: CPColors.primary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CPColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(CPRadius.pill),
                ),
                child: Text(
                  '#${entry.rank}',
                  style: CPTextStyles.labelLarge.copyWith(
                    color: CPColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CPColors.primary,
                  borderRadius: BorderRadius.circular(CPRadius.pill),
                ),
                child: Text(
                  'You',
                  style: CPTextStyles.labelSmall
                      .copyWith(color: const Color(0xFF07111D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: CPSpacing.md),
          Text(entry.username, style: CPTextStyles.headlineMedium),
          const SizedBox(height: CPSpacing.sm),
          Row(
            children: [
              _StatBadge(
                icon: Icons.flag,
                label: '${entry.solvedCount ?? 0} solves',
                color: CPColors.success,
              ),
              const SizedBox(width: CPSpacing.md),
              _StatBadge(
                icon: Icons.star,
                label: '${entry.rankPoints ?? 0} pts',
                color: CPColors.gold,
              ),
              const SizedBox(width: CPSpacing.md),
              _StatBadge(
                icon: Icons.monetization_on,
                label: '${entry.coins ?? 0} coins',
                color: CPColors.amber,
              ),
            ],
          ),
          if (entry.badges != null && entry.badges!.isNotEmpty) ...[
            const SizedBox(height: CPSpacing.md),
            Wrap(
              spacing: CPSpacing.sm,
              children: entry.badges!
                  .map((badge) => Chip(
                        label: Text(badge, style: CPTextStyles.labelSmall),
                        backgroundColor: CPColors.bg800,
                        side: const BorderSide(color: CPColors.line),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(CPRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: CPTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final CPLeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    if (rank == 1) {
      rankColor = CPColors.gold;
    } else if (rank == 2) {
      rankColor = const Color(0xFFB0B0B0);
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankColor = CPColors.muted;
    }

    return Container(
      decoration: BoxDecoration(
        color:
            isCurrentUser ? CPColors.primary.withOpacity(0.06) : CPColors.card,
        borderRadius: BorderRadius.circular(CPRadius.lg),
        border: Border.all(
          color:
              isCurrentUser ? CPColors.primary.withOpacity(0.3) : CPColors.line,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CPSpacing.lg,
          vertical: CPSpacing.sm,
        ),
        leading: SizedBox(
          width: 40,
          child: Text(
            '#$rank',
            style: CPTextStyles.titleMedium.copyWith(
              color: rankColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(entry.username, style: CPTextStyles.titleMedium),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CPColors.primary.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(CPRadius.pill),
                ),
                child: Text(
                  'You',
                  style:
                      CPTextStyles.labelSmall.copyWith(color: CPColors.primary),
                ),
              ),
          ],
        ),
        subtitle: Text(
          '${entry.solvedCount ?? 0} solves · ${entry.rankPoints ?? 0} pts',
          style: CPTextStyles.bodySmall,
        ),
        trailing: entry.coins != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on,
                      size: 16, color: CPColors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.coins}',
                    style: CPTextStyles.labelMedium
                        .copyWith(color: CPColors.amber),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}

class _LeaderboardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CPColors.bg800,
      highlightColor: CPColors.bg700,
      child: ListView.builder(
        padding: const EdgeInsets.all(CPSpacing.lg),
        itemCount: 10,
        itemBuilder: (_, __) => Card(
          margin: const EdgeInsets.only(bottom: CPSpacing.sm),
          child: ListTile(
            leading: Container(width: 40, height: 24, color: CPColors.bg800),
            title: Container(height: 20, width: 120, color: CPColors.bg800),
            subtitle: Container(height: 14, width: 100, color: CPColors.bg800),
          ),
        ),
      ),
    );
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
            Text('Failed to load leaderboard',
                style: CPTextStyles.headlineSmall),
            const SizedBox(height: CPSpacing.xs),
            Text(error,
                style: CPTextStyles.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: CPSpacing.lg),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
