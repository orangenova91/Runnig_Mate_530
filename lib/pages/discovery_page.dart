import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_card.dart';
import 'my_profile_page.dart';

class DiscoveryPage extends StatelessWidget {
  const DiscoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('로그인이 필요합니다.')));
    }

    final userService = UserService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('러닝 메이트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: '내 프로필',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyProfilePage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: '로그아웃',
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              // AuthGate가 로그아웃을 감지해 로그인 화면으로 전환합니다.
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: userService.watchDiscoverableUsers(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const EmptyState(
              icon: Icons.directions_run_outlined,
              title: '아직 매칭 가능한 러너가 없어요',
              subtitle: '프로필을 완성하면 더 많은 러너를 만날 수 있어요',
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
