import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_card.dart';

class LikesPage extends StatelessWidget {
  const LikesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('로그인이 필요합니다.')));
    }

    final userService = UserService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('관심')),
      body: StreamBuilder<List<UserProfile>>(
        stream: userService.watchLikedProfiles(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: '관심 표시한 러너가 없어요',
              subtitle: '탐색 탭에서 마음에 드는 러너에게 관심을 보내 보세요',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => ProfileCard(user: users[index]),
          );
        },
      ),
    );
  }
}
