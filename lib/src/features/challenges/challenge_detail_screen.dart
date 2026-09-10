// Challenge Detail Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/models.dart';

final challengeDetailProvider = FutureProvider.family<CPChallenge, int>((ref, id) async {
  final client = ref.watch(apiClientProvider);
  final result = await client.getChallenge(id);
  return CPChallenge.fromJson(result);
});

class ChallengeDetailScreen extends ConsumerWidget {
  final int challengeId;

  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengeAsync = ref.watch(challengeDetailProvider(challengeId));

    return Scaffold(
      body: challengeAsync.when(
        data: (challenge) => CustomScrollView(
          slivers: [
            _ChallengeDetailAppBar(challenge: challenge),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(CPSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChallengeMeta(challenge: challenge),
                    const SizedBox(height: CPSpacing.xl),
                    _ChallengeDescription(challenge: challenge),
                    const SizedBox(height: CPSpacing.xl),
                    _ChallengeHints(challenge: challenge),
                    const SizedBox(height: CPSpacing.xl),
                    _ChallengeWalkthrough(challenge: challenge),
                    const SizedBox(height: CPSpacing.xl),
                    _FlagSubmit(challenge: challenge),
                    const SizedBox(height: CPSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => _ChallengeDetailSkeleton(),
        error: (e, _) => _ChallengeDetailError(error: e.toString(), challengeId: challengeId),
      ),
    );
  }
}

class _ChallengeDetailAppBar extends StatelessWidget {
  final CPChallenge challenge;

  const _ChallengeDetailAppBar({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (challenge.telegramFileId != null)
              Image.network(
                'https://cipherpoint.linkpc.net/api/media/${challenge.telegramFileId}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: CPColors.bg800),
              )
            else
              Container(
                color: CPColors.bg800,
                child: const Center(
                  child: Icon(Icons.flag, size: 64, color: CPColors.muted),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    CPColors.bg950.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: challenge.categoryColor.withOpacity(0.16),
                border: Border.all(color: challenge.categoryColor.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(CPRadius.pill),
              ),
              child: Text(
                'lab/${challenge.category}',
                style: CPTextStyles.labelSmall.copyWith(color: challenge.categoryColor),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              challenge.title,
              style: CPTextStyles.headlineMedium.copyWith(
                shadows: [const Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2))],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeMeta extends StatelessWidget {
  final CPChallenge challenge;

  const _ChallengeMeta({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetaChip(
          icon: Icons.flag,
          label: '${challenge.pointsReward ?? 0} pts',
          color: CPColors.gold,
        ),
        const SizedBox(width: CPSpacing.sm),
        _MetaChip(
          icon: Icons.trending_up,
          label: challenge.difficultyLabel,
          color: challenge.difficultyColor,
        ),
        const SizedBox(width: CPSpacing.sm),
        if (challenge.solvedCount != null && challenge.solvedCount! > 0)
          _MetaChip(
            icon: Icons.check_circle,
            label: '${challenge.solvedCount} solves',
            color: CPColors.success,
          ),
        const Spacer(),
        if (challenge.isCommunity == true)
          Chip(
            label: Text('Community', style: CPTextStyles.labelSmall),
            backgroundColor: CPColors.purple.withOpacity(0.16),
            side: BorderSide(color: CPColors.purple.withOpacity(0.4)),
          ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(CPRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: CPTextStyles.labelMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _ChallengeDescription extends StatelessWidget {
  final CPChallenge challenge;

  const _ChallengeDescription({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: CPTextStyles.headlineSmall),
        const SizedBox(height: CPSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(CPSpacing.lg),
          decoration: BoxDecoration(
            color: CPColors.bg800,
            borderRadius: BorderRadius.circular(CPRadius.lg),
            border: Border.all(color: CPColors.line),
          ),
          child: SelectableText(
            challenge.description,
            style: CPTextStyles.bodyMedium.copyWith(height: 1.7),
          ),
        ),
      ],
    );
  }
}

class _ChallengeHints extends ConsumerWidget {
  final CPChallenge challenge;

  const _ChallengeHints({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(apiClientProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Hints', style: CPTextStyles.headlineSmall),
            Text(
              'Costs coins to unlock',
              style: CPTextStyles.bodySmall.copyWith(color: CPColors.muted),
            ),
          ],
        ),
        const SizedBox(height: CPSpacing.md),
        if (challenge.hint1 != null)
          _HintCard(
            number: 1,
            hint: challenge.hint1!,
            cost: challenge.hint1Cost ?? 10,
            onUnlock: () => _unlockHint(context, ref, 1),
          ),
        if (challenge.hint2 != null) ...[
          const SizedBox(height: CPSpacing.md),
          _HintCard(
            number: 2,
            hint: challenge.hint2!,
            cost: challenge.hint2Cost ?? 20,
            onUnlock: () => _unlockHint(context, ref, 2),
          ),
        ],
      ],
    );
  }

  Future<void> _unlockHint(BuildContext context, WidgetRef ref, int number) async {
    final client = ref.read(apiClientProvider);
    try {
      final result = await client.unlockHint(challengeId: challenge.id, hintNumber: number);
      final resp = CPHintUnlockResponse.fromJson(result);
      if (resp.success && resp.hint != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hint unlocked: ${resp.hint}')),
        );
        ref.invalidate(challengeDetailProvider(challenge.id));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message ?? 'Failed to unlock hint')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _HintCard extends StatelessWidget {
  final int number;
  final String hint;
  final int cost;
  final VoidCallback onUnlock;

  const _HintCard({
    required this.number,
    required this.hint,
    required this.cost,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CPSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Hint $number', style: CPTextStyles.titleMedium),
                const Spacer(),
                FilledButton.tonal(
                  onPressed: onUnlock,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_open, size: 16),
                      const SizedBox(width: 4),
                      Text('$cost'),
                      const Icon(Icons.monetization_on, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: CPSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(CPSpacing.md),
              decoration: BoxDecoration(
                color: CPColors.bg800,
                borderRadius: BorderRadius.circular(CPRadius.md),
                border: Border.all(color: CPColors.line),
              ),
              child: SelectableText(hint, style: CPTextStyles.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeWalkthrough extends StatelessWidget {
  final CPChallenge challenge;

  const _ChallengeWalkthrough({required this.challenge});

  @override
  Widget build(BuildContext context) {
    if (challenge.solutionWalkthrough == null || challenge.solutionWalkthrough!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Walkthrough', style: CPTextStyles.headlineSmall),
        const SizedBox(height: CPSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(CPSpacing.lg),
          decoration: BoxDecoration(
            color: CPColors.success.withOpacity(0.06),
            borderRadius: BorderRadius.circular(CPRadius.lg),
            border: Border.all(color: CPColors.success.withOpacity(0.3)),
          ),
          child: SelectableText(
            challenge.solutionWalkthrough!,
            style: CPTextStyles.bodyMedium.copyWith(height: 1.7),
          ),
        ),
      ],
    );
  }
}

class _FlagSubmit extends ConsumerWidget {
  final CPChallenge challenge;

  const _FlagSubmit({required this.challenge});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(apiClientProvider);
    final flagController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Submit Flag', style: CPTextStyles.headlineSmall),
        const SizedBox(height: CPSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(CPSpacing.lg),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Format: CIPHER{...}',
                    style: CPTextStyles.bodySmall.copyWith(color: CPColors.muted),
                  ),
                  const SizedBox(height: CPSpacing.md),
                  TextFormField(
                    controller: flagController,
                    decoration: const InputDecoration(
                      hintText: 'Enter flag here',
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Flag is required' : null,
                  ),
                  const SizedBox(height: CPSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        try {
                          final result = await client.submitFlag(
                            challengeId: challenge.id,
                            flag: flagController.text.trim(),
                          );
                          final resp = CPFlagSubmitResponse.fromJson(result);
                          if (resp.success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Correct! +${resp.pointsAwarded} pts'),
                                backgroundColor: CPColors.success,
                              ),
                            );
                            flagController.clear();
                            ref.invalidate(challengeDetailProvider(challenge.id));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(resp.message ?? 'Incorrect flag'),
                                backgroundColor: CPColors.danger,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      child: const Text('Submit Flag'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChallengeDetailSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CPColors.bg800,
      highlightColor: CPColors.bg700,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            flexibleSpace: Container(color: CPColors.bg800),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(CPSpacing.lg),
              child: Column(
                children: [
                  Container(height: 20, width: 200, color: CPColors.bg800),
                  const SizedBox(height: 16),
                  Container(height: 24, width: double.infinity, color: CPColors.bg800),
                  const SizedBox(height: 24),
                  Container(height: 80, width: double.infinity, color: CPColors.bg800),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeDetailError extends StatelessWidget {
  final String error;
  final int challengeId;

  const _ChallengeDetailError({required this.error, required this.challengeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(CPSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: CPColors.danger),
              const SizedBox(height: CPSpacing.md),
              Text('Failed to load challenge', style: CPTextStyles.headlineSmall),
              const SizedBox(height: CPSpacing.xs),
              Text(error, style: CPTextStyles.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: CPSpacing.lg),
              FilledButton(
                onPressed: () => context.go('/challenges/$challengeId'),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}