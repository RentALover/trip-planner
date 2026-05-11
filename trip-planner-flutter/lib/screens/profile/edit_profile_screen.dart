import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import 'profile_screen.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  bool _uploading = false;
  String? _avatarUrl;

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile(UserProfile p) {
    if (_loaded) return;
    _loaded = true;
    _nicknameCtrl.text = p.nickname;
    _emailCtrl.text = p.email ?? '';
    _phoneCtrl.text = p.phone ?? '';
    _bioCtrl.text = p.bio ?? '';
    _avatarUrl = p.avatarUrl;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final url = await ref.read(userServiceProvider).uploadAvatar(picked.path);
      setState(() {
        _avatarUrl = url;
        _uploading = false;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('头像已更新')));
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('上传失败: $e')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(userServiceProvider).updateProfile(UserUpdateReq(
        nickname: _nicknameCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        avatarUrl: _avatarUrl,
      ));
      ref.invalidate(profileProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑资料'),
        actions: [TextButton(onPressed: _saving ? null : _save, child: const Text('保存'))],
      ),
      body: profileAsync.when(
        loading: () => const LoadingWidget(message: '加载资料...'),
        error: (e, _) => AppErrorWidget(message: '$e', onRetry: () => ref.invalidate(profileProvider)),
        data: (profile) {
          _initFromProfile(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                          backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                          child: _avatarUrl == null
                              ? Text(profile.nickname.isNotEmpty ? profile.nickname[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary))
                              : null,
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: _uploading
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('点击更换头像', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _nicknameCtrl,
                    decoration: const InputDecoration(labelText: '昵称'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: '邮箱'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: '手机号'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioCtrl,
                    decoration: const InputDecoration(labelText: '简介'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
