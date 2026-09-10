// Settings Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/cipherpoint_theme.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/models.dart';
import '../auth/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    if (user == null) {
      return Scaffold(
        body: Center(child: FilledButton(onPressed: () => context.go('/login'), child: const Text('Login'))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(CPSpacing.lg),
        children: [
          _SettingsSection(
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: CPColors.text),
                title: Text('Edit Profile', style: CPTextStyles.bodyMedium),
                trailing: const Icon(Icons.chevron_right, color: CPColors.muted),
                onTap: () => context.push('/profile'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.md)),
                tileColor: CPColors.card,
              ),
              const SizedBox(height: CPSpacing.sm),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: CPColors.text),
                title: Text('Change Password', style: CPTextStyles.bodyMedium),
                trailing: const Icon(Icons.chevron_right, color: CPColors.muted),
                onTap: () => _showChangePasswordDialog(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.md)),
                tileColor: CPColors.card,
              ),
              const SizedBox(height: CPSpacing.sm),
              ListTile(
                leading: const Icon(Icons.telegram, color: CPColors.text),
                title: Text('Telegram Connection', style: CPTextStyles.bodyMedium),
                subtitle: Text(
                  user.telegramChatId != null ? 'Connected' : 'Not connected',
                  style: CPTextStyles.bodySmall,
                ),
                trailing: const Icon(Icons.chevron_right, color: CPColors.muted),
                onTap: () => _showTelegramDialog(context, ref),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.md)),
                tileColor: CPColors.card,
              ),
            ],
          ),
          const SizedBox(height: CPSpacing.xl),
          _SettingsSection(
            title: 'Notifications',
            children: [
              _SwitchTile(
                title: 'New Challenges',
                subtitle: 'Get notified when new challenges are published',
                value: user.notifyNewChallenges == 1,
                onChanged: (v) => _updateNotification(ref, user, 'notify_new_challenges', v),
              ),
              _SwitchTile(
                title: 'Comments',
                subtitle: 'Notify when someone comments on your challenges',
                value: user.notifyComments == 1,
                onChanged: (v) => _updateNotification(ref, user, 'notify_comments', v),
              ),
              _SwitchTile(
                title: 'Mentions',
                subtitle: 'Notify when you are mentioned in comments',
                value: user.notifyMentions == 1,
                onChanged: (v) => _updateNotification(ref, user, 'notify_mentions', v),
              ),
              _SwitchTile(
                title: 'Telegram Notifications',
                subtitle: 'Receive notifications via Telegram bot',
                value: user.telegramNotifications == 1,
                onChanged: (v) => _updateNotification(ref, user, 'telegram_notifications', v),
              ),
            ],
          ),
          const SizedBox(height: CPSpacing.xl),
          _SettingsSection(
            title: 'Privacy',
            children: [
              _SwitchTile(
                title: 'Public Profile',
                subtitle: 'Allow others to view your profile',
                value: user.publicProfile == 1,
                onChanged: (v) => _updatePrivacy(ref, user, 'public_profile', v),
              ),
              _SwitchTile(
                title: 'Hide Email',
                subtitle: 'Hide your email from public profile',
                value: user.hideEmail == 1,
                onChanged: (v) => _updatePrivacy(ref, user, 'hide_email', v),
              ),
            ],
          ),
          const SizedBox(height: CPSpacing.xl),
          _SettingsSection(
            title: 'Security',
            children: [
              ListTile(
                leading: const Icon(Icons.fingerprint, color: CPColors.text),
                title: Text('Biometric Lock', style: CPTextStyles.bodyMedium),
                subtitle: Text('Lock app with fingerprint/Face ID', style: CPTextStyles.bodySmall),
                trailing: Switch(
                  value: false,
                  onChanged: (v) {},
                  activeColor: CPColors.primary,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.md)),
                tileColor: CPColors.card,
              ),
              const SizedBox(height: CPSpacing.sm),
              ListTile(
                leading: const Icon(Icons.history, color: CPColors.text),
                title: Text('Login History', style: CPTextStyles.bodyMedium),
                trailing: const Icon(Icons.chevron_right, color: CPColors.muted),
                onTap: () {},
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.md)),
                tileColor: CPColors.card,
              ),
            ],
          ),
          const SizedBox(height: CPSpacing.xl),
          _SettingsSection(
            title: 'Danger Zone',
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: CPColors.danger),
                title: Text('Logout', style: CPTextStyles.bodyMedium.copyWith(color: CPColors.danger)),
                onTap: () => _logout(context, ref),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.md)),
                tileColor: CPColors.card,
              ),
              const SizedBox(height: CPSpacing.sm),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: CPColors.danger),
                title: Text('Delete Account', style: CPTextStyles.bodyMedium.copyWith(color: CPColors.danger)),
                subtitle: Text('Permanently delete your account and all data', style: CPTextStyles.bodySmall),
                onTap: () => _showDeleteAccountDialog(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.md)),
                tileColor: CPColors.card,
              ),
            ],
          ),
          const SizedBox(height: CPSpacing.xxxl),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CPColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.xl), side: BorderSide(color: CPColors.line)),
        title: Text('Change Password', style: CPTextStyles.headlineSmall),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: CPSpacing.md),
              TextFormField(
                controller: newController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 8 ? null : 'Min 8 characters',
              ),
              const SizedBox(height: CPSpacing.md),
              TextFormField(
                controller: confirmController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
                validator: (v) => v == newController.text ? null : 'Passwords must match',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed! (API not implemented)')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showTelegramDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CPColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.xl), side: BorderSide(color: CPColors.line)),
        title: Text('Telegram Bot', style: CPTextStyles.headlineSmall),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Connect your Telegram to receive notifications.', style: CPTextStyles.bodyMedium),
            const SizedBox(height: CPSpacing.lg),
            Text('1. Open @CipherPointBot on Telegram', style: CPTextStyles.bodySmall),
            Text('2. Send /start', style: CPTextStyles.bodySmall),
            Text('3. Send /link <your_username>', style: CPTextStyles.bodySmall),
            const SizedBox(height: CPSpacing.lg),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateNotification(WidgetRef ref, CPUser user, String field, bool value) async {
    final client = ref.read(apiClientProvider);
    try {
      await client.updateProfile({field: value ? 1 : 0});
      ref.invalidate(authStateProvider);
    } catch (_) {
      // Show error
    }
  }

  Future<void> _updatePrivacy(WidgetRef ref, CPUser user, String field, bool value) async {
    final client = ref.read(apiClientProvider);
    try {
      await client.updateProfile({field: value ? 1 : 0});
      ref.invalidate(authStateProvider);
    } catch (_) {
      // Show error
    }
  }

  void _logout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CPColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.xl), side: BorderSide(color: CPColors.line)),
        title: Text('Logout', style: CPTextStyles.headlineSmall),
        content: Text('Are you sure you want to logout?', style: CPTextStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            style: FilledButton.styleFrom(backgroundColor: CPColors.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CPColors.panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.xl), side: BorderSide(color: CPColors.line)),
        title: Text('Delete Account', style: CPTextStyles.headlineSmall.copyWith(color: CPColors.danger)),
        content: Text('This action is irreversible. All your data will be permanently deleted.', style: CPTextStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion not implemented yet')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: CPColors.danger),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CPTextStyles.headlineSmall),
        const SizedBox(height: CPSpacing.md),
        Column(children: children),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CPSpacing.sm),
      child: Card(
        child: ListTile(
          title: Text(title, style: CPTextStyles.bodyMedium),
          subtitle: Text(subtitle, style: CPTextStyles.bodySmall),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: CPColors.primary,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CPRadius.md)),
          tileColor: CPColors.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: CPSpacing.lg, vertical: CPSpacing.sm),
        ),
      ),
    );
  }
}