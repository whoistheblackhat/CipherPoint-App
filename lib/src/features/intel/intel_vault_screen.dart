// Intel Vault Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/models.dart';

final intelVaultProvider =
    FutureProvider.family<List<CPIntelArticle>, String?>((ref, category) async {
  final client = ref.watch(apiClientProvider);
  final result = await client.getIntelArticles(category: category, limit: 50);
  return result.map((e) => CPIntelArticle.fromJson(e)).toList();
});

class IntelVaultScreen extends ConsumerStatefulWidget {
  const IntelVaultScreen({super.key});

  @override
  ConsumerState<IntelVaultScreen> createState() => _IntelVaultScreenState();
}

class _IntelVaultScreenState extends ConsumerState<IntelVaultScreen> {
  String? _selectedCategory;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...CPCategories.intelCategories];
    final articlesAsync = ref.watch(
      intelVaultProvider(_selectedCategory == 'All' ? null : _selectedCategory),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intel Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showCategorySheet,
          ),
        ],
      ),
      body: Column(
        children: [
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
                    });
                  },
                  checkmarkColor: CPColors.teal,
                  side: BorderSide(
                      color: isSelected ? CPColors.teal : CPColors.line),
                  labelStyle: TextStyle(
                      color: isSelected ? CPColors.teal : CPColors.text),
                );
              },
            ),
          ),
          const SizedBox(height: CPSpacing.md),
          // Articles list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(intelVaultProvider),
              child: articlesAsync.when(
                data: (articles) {
                  if (articles.isEmpty) {
                    return _EmptyState(
                      icon: Icons.book_outlined,
                      title: 'No articles yet',
                      subtitle: _selectedCategory != null
                          ? 'No articles in this category'
                          : 'Be the first to contribute!',
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(CPSpacing.lg),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return _IntelCard(
                        article: article,
                        onTap: () => context.push('/intel/${article.id}'),
                      );
                    },
                  );
                },
                loading: () => ListView.builder(
                  padding: const EdgeInsets.all(CPSpacing.lg),
                  itemCount: 6,
                  itemBuilder: (_, __) => _IntelSkeleton(),
                ),
                error: (e, _) => _EmptyState(
                  icon: Icons.error_outline,
                  title: 'Failed to load articles',
                  subtitle: e.toString(),
                  action: TextButton(
                    onPressed: () => ref.invalidate(intelVaultProvider),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategorySheet() {
    final categories = ['All', ...CPCategories.intelCategories];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: CPColors.panel,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(CPRadius.xl)),
        ),
        padding: const EdgeInsets.all(CPSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categories', style: CPTextStyles.headlineMedium),
            const SizedBox(height: CPSpacing.lg),
            Wrap(
              spacing: CPSpacing.sm,
              runSpacing: CPSpacing.sm,
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat ||
                    (_selectedCategory == null && cat == 'All');
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (s) {
                    setState(() => _selectedCategory =
                        s ? (cat == 'All' ? null : cat) : null);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}

class _IntelCard extends StatelessWidget {
  final CPIntelArticle article;
  final VoidCallback onTap;

  const _IntelCard({required this.article, required this.onTap});

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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CPColors.teal.withOpacity(0.12),
                      border: Border.all(color: CPColors.teal.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(CPRadius.pill),
                    ),
                    child: Text(
                      'lab/${article.category}',
                      style: CPTextStyles.labelSmall
                          .copyWith(color: CPColors.teal),
                    ),
                  ),
                  const Spacer(),
                  if (article.createdAt != null)
                    Text(
                      _formatDate(article.createdAt!),
                      style: CPTextStyles.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: CPSpacing.md),
              Text(
                article.title,
                style: CPTextStyles.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (article.summary != null) ...[
                const SizedBox(height: CPSpacing.sm),
                Text(
                  article.summary!,
                  style:
                      CPTextStyles.bodyMedium.copyWith(color: CPColors.muted),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: CPSpacing.md),
              Row(
                children: [
                  if (article.authorUsername != null) ...[
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: CPColors.bg800,
                      child: Text(
                        article.authorUsername![0].toUpperCase(),
                        style: CPTextStyles.labelSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(article.authorUsername!,
                        style: CPTextStyles.bodySmall),
                  ],
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      color: CPColors.muted, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}

class _IntelSkeleton extends StatelessWidget {
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
              Container(height: 20, width: 80, color: CPColors.bg800),
              const SizedBox(height: 12),
              Container(
                  height: 24, width: double.infinity, color: CPColors.bg800),
              const SizedBox(height: 8),
              Container(height: 16, width: 200, color: CPColors.bg800),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: CPColors.bg800,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(height: 14, width: 100, color: CPColors.bg800),
                ],
              ),
            ],
          ),
        ),
      ),
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
            Text(subtitle,
                style: CPTextStyles.bodyMedium, textAlign: TextAlign.center),
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
