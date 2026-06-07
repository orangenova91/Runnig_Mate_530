import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pages/auth_gate.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RunningDateApp());
}

class RunningDateApp extends StatelessWidget {
  const RunningDateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Runnig Mate 530',
      theme: AppTheme.light,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
