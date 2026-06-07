import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error, {String fallback = '로그인에 실패했습니다.'}) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return '로그인이 취소되었습니다.';
      case 'account-exists-with-different-credential':
        return '이미 다른 방식으로 가입된 계정입니다. 이메일 로그인을 시도해 주세요.';
      case 'operation-not-allowed':
        return '카카오 로그인이 비활성화되어 있습니다. Firebase 콘솔을 확인해 주세요.';
      case 'invalid-credential':
      case 'user-disabled':
        return '로그인 정보가 올바르지 않거나 계정이 비활성화되었습니다.';
      case 'network-request-failed':
        return '네트워크 오류가 발생했습니다. 연결을 확인해 주세요.';
      case 'web-context-cancelled':
        return '로그인 창이 닫혔습니다. 다시 시도해 주세요.';
      default:
        return '$fallback (${error.code})';
    }
  }
  return fallback;
}
