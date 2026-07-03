import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'app/theme.dart';
import 'app/router.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: OrigamiLearnApp()));
}

class OrigamiLearnApp extends ConsumerWidget {
  const OrigamiLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userDocSyncProvider);

    return MaterialApp.router(
      title: 'OrigamiLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
