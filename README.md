# Runnig Mate 530

러닝 매칭 앱 — Flutter + Firebase

## 프로젝트 구조

```
Runnig Date/
├── lib/                    # Flutter 앱 코드
├── web/, android/, ios/    # 플랫폼 설정
├── pubspec.yaml
├── firebase.json           # Firebase 배포 설정 (Hosting, Rules)
├── .firebaserc             # Firebase 프로젝트 ID
├── firestore.rules         # Firestore 보안 규칙
├── storage.rules           # Storage 보안 규칙
├── scripts/                # 유틸 스크립트
└── package.json            # 배포·관리 스크립트
```

## 로컬 실행

```bash
flutter pub get
flutter run -d chrome
```

## Firebase 연결 (최초 1회)

```bash
npm install
flutter pub global activate flutterfire_cli
chmod +x scripts/configure_firebase.sh
./scripts/configure_firebase.sh
```

Firebase 콘솔에서 다음 로그인 방식을 활성화해야 합니다.

- **이메일/비밀번호**
- **OpenID Connect (OIDC)** — Provider ID: `oidc.kakao`, Issuer: `https://kauth.kakao.com`

카카오 개발자 콘솔에서 **OpenID Connect** 활성화 및 Redirect URI 등록이 필요합니다.

```
https://running-date-2ee0d.firebaseapp.com/__/auth/handler
```

## 배포

```bash
# 웹 앱 빌드 + Hosting·Rules 전체 배포
npm run deploy

# UI만 다시 배포
npm run build:web && npm run deploy:hosting

# Firestore/Storage 규칙만
npm run deploy:backend
```

배포 URL: https://running-date-2ee0d.web.app

## 앱 플로우

```
AuthGate
  ├─ 미로그인 → LoginPage
  ├─ 로그인 + 프로필 없음 → OnboardingPage
  └─ 로그인 + 프로필 있음 → MainShell (탐색 · 관심 · 프로필)
```
