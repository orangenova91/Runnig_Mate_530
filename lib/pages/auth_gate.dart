import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'login_page.dart';
import 'main_shell.dart';
import 'onboarding_page.dart';

/// 로그인 상태 + 프로필 유무에 따라 초기 화면 분기
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _activeUid;
  bool _profileReady = false;

  void _resetSession() {
    if (_activeUid == null && !_profileReady) return;
    setState(() {
      _activeUid = null;
      _profileReady = false;
    });
  }

  void _activateUser(String uid) {
    if (_activeUid == uid) return;
    setState(() {
      _activeUid = uid;
      _profileReady = false;
    });
  }

  void _markProfileReady() {
    if (_profileReady) return;
    setState(() => _profileReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting &&
            !authSnap.hasData) {
          return const _LoadingScreen();
        }

        final user = authSnap.data;
        if (user == null) {
          if (_activeUid != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _resetSession());
          }
          return const LoginPage();
        }

        if (_activeUid != user.uid) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _activateUser(user.uid),
          );
        }

        if (_profileReady) {
          return const MainShell();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, profileSnap) {
            if (profileSnap.connectionState == ConnectionState.waiting &&
                !profileSnap.hasData) {
              return const _LoadingScreen();
            }

            if (profileSnap.hasError) {
              return const _ErrorScreen(
                message: '프로필 정보를 불러오지 못했습니다.\n'
                    '잠시 후 다시 시도해 주세요.',
              );
            }

            final hasProfile = profileSnap.data?.exists ?? false;
            if (hasProfile) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _markProfileReady());
              return const MainShell();
            }

            return OnboardingPage(key: ValueKey('onboarding-${user.uid}'));
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
