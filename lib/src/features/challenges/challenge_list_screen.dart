// Challenges List Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/models.dart';

final challengesProvider =
    FutureProvider.family<List<CPChallenge>, Map<String, dynamic>>(
        (ref, params) async {
  final client = ref.watch(apiClientProvider);
  final result = await client.getChallenges(
    category: params['category'],
    difficulty: params['difficulty'],
    search: params['search'],
    limit: params['limit'] ?? 50,
    offset: params['offset'] ?? 0,
  );
  return result.map((e) => CPChallenge.fromJson(e)).toList();
});

class ChallengeListScreen extends ConsumerStatefulWidget {
  const ChallengeListScreen({super.key});

  @override
  ConsumerState<ChallengeListScreen> createState() =>
      _ChallengeListScreenState();
}

class _ChallengeListScreenState extends ConsumerState<ChallengeListScreen> {
  String? _selectedCategory;
  String? _selectedDifficulty;
  final _searchController = TextEditingController();
  int _page = 0;
  final _scrollController = ScrollController();
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    await Future.delayed(const Duration(milliseconds: 300));
    // The provider will handle pagination via offset
    setState(() => _isLoadingMore = false);
  }

  void _refresh() {
    setState(() {
      _page = 0;
      _hasMore = true;
    });
    ref.invalidate(challengesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...CPCategories.challengeCategories];
    final difficulties = ['All', 'Easy', 'Medium', 'Hard'];

    final challengesAsync = ref.watch(challengesProvider({
      'category': _selectedCategory == 'All' ? null : _selectedCategory,
      'difficulty': _selectedDifficulty == 'All' ? null : _selectedDifficulty,
      'search': _searchController.text.isEmpty ? null : _searchController.text,
      'limit': 50,
      'offset': _page * 50,
    }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(CPSpacing.lg),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search challenges...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _refresh();
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _refresh(),
            ),
          ),
          // Category chips
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: CPSpacing.lg),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: CPSpacing.sm),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat ||
                    (_selectedCategory == null && cat == 'All');
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory =
                          selected ? (cat == 'All' ? null : cat) : null;
                      _refresh();
                    });
                  },
                  selectedColor: CPColors.primary.withOpacity(0.16),
                  checkmarkColor: CPColors.primary,
                  side: BorderSide(
                      color: isSelected ? CPColors.primary : CPColors.line),
                );
              },
            ),
          ),
          // Difficulty chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: CPSpacing.lg),
              itemCount: difficulties.length,
              separatorBuilder: (_, __) => const SizedBox(width: CPSpacing.sm),
              itemBuilder: (context, index) {
                final diff = difficulties[index];
                final isSelected = _selectedDifficulty == diff ||
                    (_selectedDifficulty == null && diff == 'All');
                Color color = CPColors.muted;
                if (diff == 'Easy') color = CPColors.success;
                if (diff == 'Medium') color = CPColors.amber;
                if (diff == 'Hard') color = CPColors.danger;
                return FilterChip(
                  label: Text(diff),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty =
                          selected ? (diff == 'All' ? null : diff) : null;
                      _refresh();
                    });
                  },
                  selectedColor: color.withOpacity(0.16),
                  checkmarkColor: color,
                  side: BorderSide(color: isSelected ? color : CPColors.line),
                  labelStyle:
                      TextStyle(color: isSelected ? color : CPColors.text),
                );
              },
            ),
          ),
          const SizedBox(height: CPSpacing.md),
          // Challenges list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: challengesAsync.when(
                data: (challenges) {
                  if (challenges.isEmpty) {
                    return _EmptyState(
                      icon: Icons.flag_outlined,
                      title: 'No challenges found',
                      subtitle: 'Try adjusting your filters',
                      action: TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _selectedDifficulty = null;
                            _searchController.clear();
                          });
                          _refresh();
                        },
                        child: const Text('Clear filters'),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(CPSpacing.lg),
                    itemCount: challenges.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= challenges.length) {
                        return const Padding(
                          padding: EdgeInsets.all(CPSpacing.lg),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final c = challenges[index];
                      return _ChallengeListItem(
                        challenge: c,
                        onTap: () => context.push('/challenges/${c.id}'),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(CPSpacing.lg),
                  itemCount: 6,
                  itemBuilder: (_, __) => _ChallengeSkeleton(),
                ),
                error: (e, _) => _EmptyState(
                  icon: Icons.error_outline,
                  title: 'Failed to load challenges',
                  subtitle: e.toString(),
                  action: TextButton(
                      onPressed: _refresh, child: const Text('Retry')),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(
        selectedCategory: _selectedCategory,
        selectedDifficulty: _selectedDifficulty,
        onApply: (cat, diff) {
          setState(() {
            _selectedCategory = cat;
            _selectedDifficulty = diff;
            _refresh();
          });
        },
      ),
    );
  }
}

class _ChallengeListItem extends StatelessWidget {
  final CPChallenge challenge;
  final VoidCallback onTap;

  const _ChallengeListItem({required this.challenge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: CPSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CPRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(CPSpacing.lg),
          child: Row(
            children: [
              if (challenge.telegramFileId != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(CPRadius.md),
                  child: SizedBox(
                    width: 80,
                    height: 60,
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
                const SizedBox(width: CPSpacing.md),
              ],
              Expanded(
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
                                color:
                                    challenge.categoryColor.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(CPRadius.pill),
                          ),
                          child: Text(
                            'lab/${challenge.category}',
                            style: CPTextStyles.labelSmall
                                .copyWith(color: challenge.categoryColor),
                          ),
                        ),
                        const SizedBox(width: CPSpacing.sm),
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
                            style: CPTextStyles.labelSmall.copyWith(
                              color: challenge.difficultyColor,
                            ),
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
                        const Icon(Icons.flag, size: 14, color: CPColors.muted),
                        const SizedBox(width: 4),
                        Text('${challenge.pointsReward ?? 0} pts',
                            style: CPTextStyles.bodySmall),
                        const SizedBox(width: 12),
                        if (challenge.solvedCount != null &&
                            challenge.solvedCount! > 0) ...[
                          const Icon(Icons.check_circle,
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
              const Icon(Icons.chevron_right, color: CPColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: CPColors.bg800,
      highlightColor: CPColors.bg700,
      child: Card(
        margin: const EdgeInsets.only(bottom: CPSpacing.md),
        child: Padding(
          padding: const EdgeInsets.all(CPSpacing.lg),
          child: Row(
            children: [
              Container(width: 80, height: 60, color: CPColors.bg800),
              const SizedBox(width: CPSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 80, color: CPColors.bg800),
                    const SizedBox(height: 8),
                    Container(
                        height: 20,
                        width: double.infinity,
                        color: CPColors.bg800),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 120, color: CPColors.bg800),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedDifficulty;
  final Function(String?, String?) onApply;

  const _FilterSheet({
    required this.selectedCategory,
    required this.selectedDifficulty,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CPColors.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(CPRadius.xl)),
      ),
      padding: const EdgeInsets.all(CPSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: CPTextStyles.headlineMedium),
          const SizedBox(height: CPSpacing.lg),
          Text('Category', style: CPTextStyles.labelMedium),
          const SizedBox(height: CPSpacing.sm),
          Wrap(
            spacing: CPSpacing.sm,
            runSpacing: CPSpacing.sm,
            children: ['All', ...CPCategories.challengeCategories].map((cat) {
              final isSelected = selectedCategory == cat ||
                  (selectedCategory == null && cat == 'All');
              return FilterChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (s) => onApply(
                  s ? (cat == 'All' ? null : cat) : null,
                  selectedDifficulty,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: CPSpacing.lg),
          Text('Difficulty', style: CPTextStyles.labelMedium),
          const SizedBox(height: CPSpacing.sm),
          Wrap(
            spacing: CPSpacing.sm,
            children: ['All', 'Easy', 'Medium', 'Hard'].map((diff) {
              final isSelected = selectedDifficulty == diff ||
                  (selectedDifficulty == null && diff == 'All');
              return FilterChip(
                label: Text(diff),
                selected: isSelected,
                onSelected: (s) => onApply(
                  selectedCategory,
                  s ? (diff == 'All' ? null : diff) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: CPSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onApply(null, null),
                  child: const Text('Clear all'),
                ),
              ),
              const SizedBox(width: CPSpacing.md),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget action;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
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
            Text(subtitle,
                style: CPTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: CPSpacing.xl),
            action,
          ],
        ),
      ),
    );
  }
}
