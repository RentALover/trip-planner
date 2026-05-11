import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name
          Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                backgroundImage: authState.user?.avatarUrl != null
                    ? NetworkImage(authState.user!.avatarUrl!)
                    : null,
                child: authState.user?.avatarUrl == null
                    ? Text(
                        (authState.user?.displayName ?? '?')[0].toUpperCase(),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                authState.user?.displayName ?? '未登录',
                style: const TextStyle(fontFamily: 'NotoSerifSC', fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                '@${authState.user?.username ?? ''}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Profile detail card
          profileAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppColors.primary))),
            error: (e, _) => const SizedBox.shrink(),
            data: (profile) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.email_outlined, '邮箱', profile.email ?? '未设置'),
                  const Divider(height: 24),
                  _infoRow(Icons.phone_outlined, '手机', profile.phone ?? '未设置'),
                  const Divider(height: 24),
                  _infoRow(Icons.info_outline, '简介', profile.bio ?? '未设置'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          _actionCard(
            icon: Icons.edit_outlined,
            title: '编辑资料',
            onTap: () => context.push(RoutePaths.editProfile),
          ),
          const SizedBox(height: 8),
          _actionCard(
            icon: Icons.lock_outlined,
            title: '修改密码',
            onTap: () => _showChangePasswordDialog(context, ref),
          ),
          const SizedBox(height: 8),
          _actionCard(
            icon: Icons.logout,
            title: '退出登录',
            color: AppColors.danger,
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(RoutePaths.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      ],
    );
  }

  Widget _actionCard({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontSize: 15, color: color ?? AppColors.textPrimary)),
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: AppColors.textPlaceholder),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: '旧密码')),
            const SizedBox(height: 12),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: '新密码')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(onPressed: () async {
            try {
              await ref.read(userServiceProvider).changePassword(
                PasswordChangeReq(oldPassword: oldCtrl.text, newPassword: newCtrl.text),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('密码修改成功')));
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('修改失败: $e')));
            }
          }, child: const Text('确认')),
        ],
      ),
    );
  }
}

final profileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.read(userServiceProvider).getProfile();
});
