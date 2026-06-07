import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../utils/auth_error_messages.dart';
import '../widgets/app_text_field.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_hero.dart';
import '../widgets/kakao_login_button.dart';
import '../widgets/primary_button.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _kakaoLoading = false;
  String? _error;

  bool get _isBusy => _loading || _kakaoLoading;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      setState(() => _error = '로그인에 실패했습니다. 이메일과 비밀번호를 확인해 주세요.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithKakao() async {
    setState(() {
      _kakaoLoading = true;
      _error = null;
    });
    try {
      await _auth.signInWithKakao();
    } catch (e) {
      setState(() => _error = authErrorMessage(e, fallback: '카카오 로그인에 실패했습니다.'));
    } finally {
      if (mounted) setState(() => _kakaoLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AuthHero(
              title: '다시 만나서 반가워요',
              subtitle: '오늘도 함께 뛸 메이트를 찾아보세요',
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
                      KakaoLoginButton(
                        loading: _kakaoLoading,
                        onPressed: _isBusy ? null : _loginWithKakao,
                      ),
                      const SizedBox(height: 20),
                      const AuthDivider(),
                      const SizedBox(height: 20),
                      AppTextField(
                        controller: _emailController,
                        label: '이메일',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isBusy,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passwordController,
                        label: '비밀번호',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        enabled: !_isBusy,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        AuthErrorBanner(message: _error!),
                      ],
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: '이메일로 로그인',
                        loading: _loading,
                        onPressed: _isBusy ? null : _login,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: _isBusy
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpPage(),
                                    ),
                                  ),
                          child: Text(
                            '계정이 없으신가요? 회원가입',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.primary),
                          ),
                        ),
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
