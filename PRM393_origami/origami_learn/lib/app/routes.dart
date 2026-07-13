/// Tên route dùng với go_router — tránh hard-code string rải rác.
abstract final class AppRoutes {
  static const onboarding = 'onboarding';
  static const auth = 'auth';
  static const home = 'home';
  static const wordVault = 'wordVault';
  static const profile = 'profile';
  static const collectionDetail = 'collectionDetail';
  static const modelDetail = 'modelDetail';
  static const foldStep = 'foldStep';
  static const foldModule = 'foldModule';
  static const assembly = 'assembly';
  static const complete = 'complete';
  static const vocabReview = 'vocabReview';

  /// Query key cho tab Home (0 = home, 1 = word vault, 2 = profile).
  static const tabQuery = 'tab';
}
