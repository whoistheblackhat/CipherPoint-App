// Notifications Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/models.dart';

final notificationsProvider = FutureProvider<List<CPNotification>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final result = await client.getNotifications(limit: 100);
  return result.map((e) => CPNotification.fromJson(e)).toList();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final async = ref.watch(notificationsProvider);
              if (async.hasValue && async.value!.any((n) => n.read == false)) {
                return TextButton(
                  onPressed: () => _markAllRead(ref),
                  child: Text(
                    'Mark all read',
                    style: CPTextStyles.labelMedium
                        .copyWith(color: CPColors.primary),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const _EmptyState(
              icon: Icons.notifications_none,
              title: 'No notifications',
              subtitle: 'You\'re all caught up!',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(CPSpacing.lg),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return _NotificationTile(
                notification: n,
                onTap: () => _handleTap(context, ref, n),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(CPSpacing.lg),
          itemCount: 6,
          itemBuilder: (_, __) => _NotificationSkeleton(),
        ),
        error: (e, _) => _EmptyState(
          icon: Icons.error_outline,
          title: 'Failed to load',
          subtitle: e.toString(),
          action: TextButton(
            onPressed: () => ref.invalidate(notificationsProvider),
            child: const Text('Retry'),
          ),
        ),
      ),
    );
  }

  Future<void> _markAllRead(WidgetRef ref) async {
    final client = ref.read(apiClientProvider);
    final notifications = ref.read(notificationsProvider).value ?? [];
    for (final n in notifications) {
      if (n.read == false) {
        try {
          await client.markNotificationRead(n.id);
        } catch (_) {}
      }
    }
    ref.invalidate(notificationsProvider);
  }

  void _handleTap(BuildContext context, WidgetRef ref, CPNotification n) {
    if (n.read == false) {
      final client = ref.read(apiClientProvider);
      client.markNotificationRead(n.id);
      ref.invalidate(notificationsProvider);
    }
    // Navigate based on notification type
    if (n.data != null) {
      if (n.data!['challenge_id'] != null) {
        context.push('/challenges/${n.data!['challenge_id']}');
      } else if (n.data!['article_id'] != null) {
        context.push('/intel/${n.data!['article_id']}');
      }
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final CPNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIcon(notification.type);
    final color = _getColor(notification.type);

    return Card(
      margin: const EdgeInsets.only(bottom: CPSpacing.md),
      color: notification.read == true
          ? CPColors.card
          : CPColors.primary.withOpacity(0.04),
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CPRadius.lg),
        side: BorderSide(
          color: notification.read == true
              ? CPColors.line
              : CPColors.primary.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CPRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(CPSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(CPRadius.md),
                ),
                child: Icon(iconData, color: color, size: 22),
              ),
              const SizedBox(width: CPSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: CPTextStyles.titleMedium.copyWith(
                              fontWeight: notification.read == true
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (notification.read != true)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: CPColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: CPSpacing.xs),
                    Text(
                      notification.body,
                      style: CPTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: CPSpacing.xs),
                    Text(
                      _formatDate(notification.createdAt),
                      style: CPTextStyles.bodySmall,
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

  IconData _getIcon(String type) {
    switch (type) {
      case 'challenge_solved':
        return Icons.flag;
      case 'comment':
        return Icons.comment;
      case 'mention':
        return Icons.alternate_email;
      case 'new_challenge':
        return Icons.add_circle;
      case 'rank_change':
        return Icons.trending_up;
      case 'badge_earned':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'challenge_solved':
        return CPColors.success;
      case 'comment':
        return CPColors.primary;
      case 'mention':
        return CPColors.amber;
      case 'new_challenge':
        return CPColors.teal;
      case 'rank_change':
        return CPColors.gold;
      case 'badge_earned':
        return CPColors.purple;
      default:
        return CPColors.muted;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}

class _NotificationSkeleton extends StatelessWidget {
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CPColors.bg800,
                  borderRadius: BorderRadius.circular(CPRadius.md),
                ),
              ),
              const SizedBox(width: CPSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 18,
                        width: double.infinity,
                        color: CPColors.bg800),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 200, color: CPColors.bg800),
                    const SizedBox(height: 8),
                    Container(height: 12, width: 80, color: CPColors.bg800),
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
