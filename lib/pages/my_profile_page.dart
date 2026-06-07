import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../utils/profile_constants.dart';
import '../widgets/primary_button.dart';
import '../widgets/storage_image.dart';
import 'edit_profile_page.dart';

class MyProfilePage extends StatelessWidget {
  const MyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('로그인이 필요합니다.')));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('내 프로필')),
      body: StreamBuilder<UserProfile?>(
        stream: UserService().watchMyProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('프로필을 찾을 수 없습니다.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: AppTheme.cardDecoration,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _ProfileAvatar(photoUrl: profile.photoUrl),
                      const SizedBox(height: 16),
                      Text(
                        '${profile.name}, ${profile.age}',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontSize: 22,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.avgPace,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _InfoSection(
                  title: '러닝 정보',
                  children: [
                    _InfoRow(
                      icon: Icons.speed_outlined,
                      label: '평균 페이스',
                      value: profile.avgPace,
                    ),
                    _InfoRow(
                      icon: Icons.directions_run_outlined,
                      label: '러닝 스타일',
                      value: ProfileConstants.runStyleLabel(profile.runStyle),
                    ),
                    if (profile.preferredTime.isNotEmpty)
                      _InfoRow(
                        icon: Icons.schedule_outlined,
                        label: '선호 시간대',
                        value: profile.preferredTime
                            .map(ProfileConstants.timeLabel)
                            .join(' · '),
                      ),
                    if (profile.courseName.isNotEmpty)
                      _InfoRow(
                        icon: Icons.place_outlined,
                        label: '코스',
                        value: profile.courseName,
                      ),
                  ],
                ),
                if (profile.paceVerifyPhotoUrl.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoSection(
                    title: '러닝 인증샷',
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          height: 160,
                          width: double.infinity,
                          child: StorageImage(
                            url: profile.paceVerifyPhotoUrl,
                            fit: BoxFit.cover,
                            errorWidget: const SizedBox(
                              height: 80,
                              child: Center(
                                child: Text('이미지를 불러올 수 없습니다.'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: '프로필 수정',
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(profile: profile),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl.isNotEmpty
          ? StorageImage(url: photoUrl, fit: BoxFit.cover)
          : const ColoredBox(
              color: AppTheme.background,
              child: Icon(Icons.person_outline, size: 48, color: AppTheme.border),
            ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
