// Intel Article Detail Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/models.dart';

final intelArticleProvider = FutureProvider.family<CPIntelArticle, int>((ref, id) async {
  final client = ref.watch(apiClientProvider);
  final result = await client.getIntelArticle(id);
  return CPIntelArticle.fromJson(result);
});

class IntelArticleScreen extends ConsumerWidget {
  final int articleId;

  const IntelArticleScreen({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(intelArticleProvider(articleId));

    return Scaffold(
      body: articleAsync.when(
        data: (article) => CustomScrollView(
          slivers: [
            _ArticleAppBar(article: article),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(CPSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ArticleMeta(article: article),
                    const SizedBox(height: CPSpacing.xl),
                    if (article.telegramFileId != null)
                      _ArticleMedia(fileId: article.telegramFileId!),
                    const SizedBox(height: CPSpacing.xl),
                    _ArticleContent(article: article),
                    const SizedBox(height: CPSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => _ArticleSkeleton(),
        error: (e, _) => _ArticleError(error: e.toString(), articleId: articleId),
      ),
    );
  }
}

class _ArticleAppBar extends StatelessWidget {
  final CPIntelArticle article;

  const _ArticleAppBar({required this.article});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: article.telegramFileId != null ? 280 : 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: article.telegramFileId != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://cipherpoint.linkpc.net/api/media/${article.telegramFileId}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: CPColors.bg800),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, CPColors.bg950.withOpacity(0.9)],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                color: CPColors.bg800,
                child: const Center(
                  child: Icon(Icons.article, size: 64, color: CPColors.muted),
                ),
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
                color: CPColors.teal.withOpacity(0.16),
                border: Border.all(color: CPColors.teal.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(CPRadius.pill),
              ),
              child: Text(
                'lab/${article.category}',
                style: CPTextStyles.labelSmall.copyWith(color: CPColors.teal),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              article.title,
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

class _ArticleMeta extends StatelessWidget {
  final CPIntelArticle article;

  const _ArticleMeta({required this.article});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: CPColors.teal.withOpacity(0.12),
            border: Border.all(color: CPColors.teal.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(CPRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.tag, size: 14, color: CPColors.teal),
              const SizedBox(width: 6),
              Text('lab/${article.category}', style: CPTextStyles.labelMedium.copyWith(color: CPColors.teal)),
            ],
          ),
        ),
        const Spacer(),
        if (article.createdAt != null)
          Text(_formatDate(article.createdAt!), style: CPTextStyles.bodySmall),
      ],
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

class _ArticleMedia extends StatelessWidget {
  final String fileId;

  const _ArticleMedia({required this.fileId});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(CPRadius.lg),
      child: Image.network(
        'https://cipherpoint.linkpc.net/api/media/$fileId',
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          height: 200,
          color: CPColors.bg800,
          child: const Center(child: Icon(Icons.broken_image, color: CPColors.muted)),
        ),
      ),
    );
  }
}

class _ArticleContent extends StatelessWidget {
  final CPIntelArticle article;

  const _ArticleContent({required this.article});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (article.summary != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(CPSpacing.lg),
            decoration: BoxDecoration(
              color: CPColors.teal.withOpacity(0.06),
              borderRadius: BorderRadius.circular(CPRadius.lg),
              border: Border.all(color: CPColors.teal.withOpacity(0.3)),
            ),
            child: Text(article.summary!, style: CPTextStyles.bodyMedium.copyWith(height: 1.7)),
          ),
          const SizedBox(height: CPSpacing.lg),
        ],
        SelectableText(
          article.content,
          style: CPTextStyles.bodyLarge.copyWith(height: 1.8),
        ),
      ],
    );
  }
}

class _ArticleSkeleton extends StatelessWidget {
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
                  Container(height: 20, width: 100, color: CPColors.bg800),
                  const SizedBox(height: 16),
                  Container(height: 200, width: double.infinity, color: CPColors.bg800),
                  const SizedBox(height: 24),
                  Container(height: 400, width: double.infinity, color: CPColors.bg800),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleError extends StatelessWidget {
  final String error;
  final int articleId;

  const _ArticleError({required this.error, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intel Vault')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(CPSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: CPColors.danger),
              const SizedBox(height: CPSpacing.md),
              Text('Failed to load article', style: CPTextStyles.headlineSmall),
              const SizedBox(height: CPSpacing.xs),
              Text(error, style: CPTextStyles.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: CPSpacing.lg),
              FilledButton(
                onPressed: () => context.go('/intel/$articleId'),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}