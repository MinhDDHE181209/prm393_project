import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/collection_model.dart';
import '../models/origami_model.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/home_screen.dart';
import '../screens/collection_detail_screen.dart';
import '../screens/model_detail_screen.dart';
import '../screens/fold_step_screen.dart';
import '../screens/fold_module_screen.dart';
import '../screens/assembly_screen.dart';
import '../screens/complete_screen.dart';
import '../services/origami_service.dart';
import 'route_model_loader.dart';
import 'routes.dart';
import 'theme.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/onboarding',
    observers: [homeRouteObserver],
    routes: [
      GoRoute(
        path: '/onboarding',
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoutes.home,
        builder: (context, state) {
          final tab = int.tryParse(state.uri.queryParameters[AppRoutes.tabQuery] ?? '0') ?? 0;
          return HomeScreen(initialTab: tab.clamp(0, 2));
        },
      ),
      GoRoute(
        path: '/word-vault',
        name: AppRoutes.wordVault,
        builder: (context, state) => const HomeScreen(initialTab: 1),
      ),
      GoRoute(
        path: '/profile',
        name: AppRoutes.profile,
        builder: (context, state) => const HomeScreen(initialTab: 2),
      ),
      GoRoute(
        path: '/word-vault/review',
        name: AppRoutes.vocabReview,
        builder: (context, state) => const _VocabReviewRoute(),
      ),
      GoRoute(
        path: '/collection/:collectionId',
        name: AppRoutes.collectionDetail,
        builder: (context, state) {
          final collectionId = state.pathParameters['collectionId']!;
          final extra = state.extra;
          if (extra is CollectionModel) {
            return CollectionDetailScreen(collection: extra);
          }
          return _CollectionRouteLoader(collectionId: collectionId);
        },
      ),
      GoRoute(
        path: '/model/:modelId',
        name: AppRoutes.modelDetail,
        builder: (context, state) {
          final modelId = state.pathParameters['modelId']!;
          final extra = state.extra;
          if (extra is OrigamiModel) {
            return ModelDetailScreen(model: extra);
          }
          return RouteModelLoader(
            modelId: modelId,
            builder: (model) => ModelDetailScreen(model: model),
          );
        },
      ),
      GoRoute(
        path: '/fold/step/:modelId',
        name: AppRoutes.foldStep,
        builder: (context, state) {
          final modelId = state.pathParameters['modelId']!;
          return RouteModelLoader(
            modelId: modelId,
            builder: (model) => FoldStepScreen(model: model),
          );
        },
      ),
      GoRoute(
        path: '/fold/module/:modelId',
        name: AppRoutes.foldModule,
        builder: (context, state) {
          final modelId = state.pathParameters['modelId']!;
          return RouteModelLoader(
            modelId: modelId,
            builder: (model) => FoldModuleScreen(model: model),
          );
        },
      ),
      GoRoute(
        path: '/fold/assembly/:modelId',
        name: AppRoutes.assembly,
        builder: (context, state) {
          final modelId = state.pathParameters['modelId']!;
          return RouteModelLoader(
            modelId: modelId,
            builder: (model) => AssemblyScreen(model: model),
          );
        },
      ),
      GoRoute(
        path: '/fold/complete/:modelId',
        name: AppRoutes.complete,
        builder: (context, state) {
          final modelId = state.pathParameters['modelId']!;
          return RouteModelLoader(
            modelId: modelId,
            builder: (model) => CompleteScreen(model: model),
          );
        },
      ),
    ],
  );
}

class _CollectionRouteLoader extends StatelessWidget {
  final String collectionId;
  const _CollectionRouteLoader({required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CollectionModel>>(
      future: OrigamiService().getCollections(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: AppTheme.amber)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: Center(child: Text('${snapshot.error}')),
          );
        }
        final collections = snapshot.data!;
        CollectionModel? collection;
        for (final c in collections) {
          if (c.id == collectionId) {
            collection = c;
            break;
          }
        }
        if (collection == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Lỗi')),
            body: const Center(child: Text('Không tìm thấy bộ sưu tập')),
          );
        }
        return CollectionDetailScreen(collection: collection);
      },
    );
  }
}

/// Màn ôn tập nhanh — mở Word Vault tab với filter "Cần ôn".
class _VocabReviewRoute extends StatelessWidget {
  const _VocabReviewRoute();

  @override
  Widget build(BuildContext context) {
    return const HomeScreen(initialTab: 1);
  }
}
