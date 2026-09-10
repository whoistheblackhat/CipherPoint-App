// Community Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/models.dart';

final communityChallengesProvider = FutureProvider<List<CPChallenge>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final result = await client.getCommunityChallenges(limit: 50);
  return result.map((e) => CPChallenge.fromJson(e)).toList();
});

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengesAsync = ref.watch(communityChallengesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community CTF Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(),
            tooltip: 'Create Challenge',
          ),
        ],
      ),
      body: challengesAsync.when(
        data: (challenges) {
          if (challenges.isEmpty) {
            return _EmptyState(
              icon: Icons.people_outline,
              title: 'No community challenges yet',
              subtitle: 'Create the first one!',
              action: FilledButton.icon(
                onPressed: _showCreateDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Challenge'),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(communityChallengesProvider),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(CPSpacing.lg),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final c = challenges[index];
                return _CommunityCard(
                  challenge: c,
                  onTap: () => context.push('/challenges/${c.id}'),
                );
              },
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(CPSpacing.lg),
          itemCount: 6,
          itemBuilder: (_, __) => _CommunitySkeleton(),
        ),
        error: (e, _) => _EmptyState(
          icon: Icons.error_outline,
          title: 'Failed to load challenges',
          subtitle: e.toString(),
          action: TextButton(
            onPressed: () => ref.invalidate(communityChallengesProvider),
            child: const Text('Retry'),
          ),
        ),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateChallengeDialog(),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CPChallenge challenge;
  final VoidCallback onTap;

  const _CommunityCard({required this.challenge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: CPSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CPRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(CPSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: challenge.categoryColor.withOpacity(0.12),
                      border: Border.all(color: challenge.categoryColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(CPRadius.pill),
                    ),
                    child: Text(
                      'lab/${challenge.category}',
                      style: CPTextStyles.labelSmall.copyWith(color: challenge.categoryColor),
                    ),
                  ),
                  const SizedBox(width: CPSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: challenge.difficultyColor.withOpacity(0.12),
                      border: Border.all(color: challenge.difficultyColor.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(CPRadius.pill),
                    ),
                    child: Text(
                      challenge.difficultyLabel,
                      style: CPTextStyles.labelSmall.copyWith(color: challenge.difficultyColor),
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text('Community', style: CPTextStyles.labelSmall),
                    backgroundColor: CPColors.purple.withOpacity(0.16),
                    side: BorderSide(color: CPColors.purple.withOpacity(0.4)),
                  ),
                ],
              ),
              const SizedBox(height: CPSpacing.md),
              Text(
                challenge.title,
                style: CPTextStyles.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: CPSpacing.sm),
              Row(
                children: [
                  Icon(Icons.flag, size: 14, color: CPColors.muted),
                  const SizedBox(width: 4),
                  Text('${challenge.pointsReward ?? 0} pts', style: CPTextStyles.bodySmall),
                  const SizedBox(width: 12),
                  if (challenge.solvedCount != null && challenge.solvedCount! > 0) ...[
                    Icon(Icons.check_circle, size: 14, color: CPColors.success),
                    const SizedBox(width: 4),
                    Text(
                      '${challenge.solvedCount} solves',
                      style: CPTextStyles.bodySmall.copyWith(color: CPColors.success),
                    ),
                  ],
                  const Spacer(),
                  if (challenge.createdBy != null)
                    Text('by User #${challenge.createdBy}', style: CPTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunitySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CPColors.bg800,
      highlightColor: CPColors.bg700,
      child: Card(
        margin: const EdgeInsets.only(bottom: CPSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(CPSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20, width: 100, color: CPColors.bg800),
              const SizedBox(height: 12),
              Container(height: 24, width: double.infinity, color: CPColors.bg800),
              const SizedBox(height: 8),
              Container(height: 14, width: 150, color: CPColors.bg800),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateChallengeDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateChallengeDialog> createState() => _CreateChallengeDialogState();
}

class _CreateChallengeDialogState extends ConsumerState<_CreateChallengeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _flagController = TextEditingController();
  String _category = 'Web';
  String _difficulty = 'Easy';
  int _points = 100;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _flagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: CPColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CPRadius.xl),
        side: BorderSide(color: CPColors.line),
      ),
      title: Text('Create Community Challenge', style: CPTextStyles.headlineSmall),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: CPSpacing.md),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: CPCategories.challengeCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: CPSpacing.md),
                DropdownButtonFormField<String>(
                  value: _difficulty,
                  decoration: const InputDecoration(labelText: 'Difficulty'),
                  items: ['Easy', 'Medium', 'Hard'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => _difficulty = v!),
                ),
                const SizedBox(height: CPSpacing.md),
                TextFormField(
                  controller: _flagController,
                  decoration: const InputDecoration(labelText: 'Flag (e.g., CIPHER{...})'),
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: CPSpacing.md),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 4,
                  validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: CPSpacing.md),
                TextFormField(
                  initialValue: _points.toString(),
                  decoration: const InputDecoration(labelText: 'Points'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => _points = int.tryParse(v) ?? 100,
                ),
],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);
    // TODO: Implement actual API call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Challenge created! (API not implemented yet)')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CPSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: CPColors.muted),
            const SizedBox(height: CPSpacing.lg),
            Text(title, style: CPTextStyles.headlineSmall),
            const SizedBox(height: CPSpacing.sm),
            Text(subtitle, style: CPTextStyles.bodyMedium, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: CPSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}