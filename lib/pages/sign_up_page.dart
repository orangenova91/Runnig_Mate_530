import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_hero.dart';
import '../widgets/primary_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.signUp(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      // AuthGate가 온보딩 화면으로 전환합니다. 회원가입 페이지만 닫습니다.
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = _signUpErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _signUpErrorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return '이미 사용 중인 이메일입니다.';
        case 'weak-password':
          return '비밀번호는 6자 이상이어야 합니다.';
        case 'invalid-email':
          return '올바른 이메일 형식이 아닙니다.';
        case 'operation-not-allowed':
          return '이메일 회원가입이 비활성화되어 있습니다. Firebase 콘솔을 확인해 주세요.';
        case 'configuration-not-found':
          return 'Firebase Authentication이 아직 설정되지 않았습니다.\n'
              'Firebase 콘솔 → Authentication → 시작하기 → 이메일/비밀번호 활성화가 필요합니다.';
        default:
          return '회원가입에 실패했습니다. (${e.code})';
      }
    }
    return '회원가입에 실패했습니다. 다시 시도해 주세요.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHero(
              title: '함께 뛸 준비됐나요?',
              subtitle: '프로필을 만들고 러닝 메이트를 만나보세요',
              showBackButton: true,
            ),
            Transform.translate(
              offset: const Offset(0, -24),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _emailController,
                        label: '이메일',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: '비밀번호',
                        hint: '6자 이상',
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 18,
                                color: AppTheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: AppTheme.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: '가입하기',
                        loading: _loading,
                        onPressed: _signUp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
