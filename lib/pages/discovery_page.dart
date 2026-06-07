import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/profile_card.dart';

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final _userService = UserService();
  String? _actingOnUid;

  Future<void> _like(String currentUid, String targetUid) async {
    setState(() => _actingOnUid = targetUid);
    try {
      await _userService.likeUser(currentUid, targetUid);
    } finally {
      if (mounted) setState(() => _actingOnUid = null);
    }
  }

  Future<void> _pass(String currentUid, String targetUid) async {
    setState(() => _actingOnUid = targetUid);
    try {
      await _userService.passUser(currentUid, targetUid);
    } finally {
      if (mounted) setState(() => _actingOnUid = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('로그인이 필요합니다.')));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('러닝 메이트')),
      body: StreamBuilder<List<UserProfile>>(
        stream: _userService.watchDiscoverableUsers(uid),
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
              subtitle: '관심을 보낸 러너는 관심 탭에서 확인할 수 있어요',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final user = users[index];
              final isLoading = _actingOnUid == user.uid;

              return Column(
                children: [
                  ProfileCard(user: user),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => _pass(uid, user.uid),
                          child: const Text('패스'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: isLoading
                              ? null
                              : () => _like(uid, user.uid),
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.favorite, size: 18),
                          label: const Text('관심 있어요'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
