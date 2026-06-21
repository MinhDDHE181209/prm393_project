import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/theme.dart';
import 'screens/screens/s01_onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const OrigamiLearnApp());
}

class OrigamiLearnApp extends StatelessWidget {
  const OrigamiLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrigamiLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // TODO: thay bằng MaterialApp.router(routerConfig: AppRouter.router)
      // ngay khi router.dart được mở comment lại (sau khi có S02, S03).
      home: const OnboardingScreen(),
    );
  }
}
