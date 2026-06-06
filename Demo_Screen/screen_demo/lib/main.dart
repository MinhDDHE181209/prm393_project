import 'package:flutter/material.dart';
import 'screens/s01_onboarding.dart';
import 'screens/s02_auth.dart';
import 'screens/main_tab_wrapper.dart';
import 'screens/s06_collection_detail.dart';
import 'screens/s07_model_detail.dart';
import 'screens/s09_fold_step_target.dart';
import 'screens/s10_fold_step_module.dart';
import 'screens/s11_assembly_guide.dart';
import 'screens/s12_complete_quiz.dart';

void main() {
  runApp(const OrigamiLearnApp());
}

class OrigamiLearnApp extends StatelessWidget {
  const OrigamiLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrigamiLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff060608),
        cardColor: const Color(0xff0e0e14),
        dividerColor: const Color(0xff202030),
        primaryColor: const Color(0xff4083ff),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff4083ff),
          secondary: Color(0xff1ebd59),
          surface: Color(0xff0e0e14),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xfff8f8fc), fontFamily: 'Inter'),
          bodyMedium: TextStyle(color: Color(0xff9292a9), fontFamily: 'Inter'),
        ),
      ),
      initialRoute: '/s01',
      routes: {
        '/s01': (context) => const S01OnboardingScreen(),
        '/s02': (context) => const S02AuthScreen(),
        '/main_tabs': (context) => const MainTabWrapper(),
        '/s06': (context) => const S06CollectionDetailScreen(),
        '/s07': (context) => const S07ModelDetailScreen(),
        '/s09': (context) => const S09FoldStepTargetScreen(),
        '/s10': (context) => const S10FoldStepModuleScreen(),
        '/s11': (context) => const S11AssemblyGuideScreen(),
        '/s12': (context) => const S12CompleteQuizScreen(),
      },
    );
  }
}