

part of 'app_router.dart';




String _$appRouterHash() => r'664c4b0eda9a61197ae7840e120e2a07fdea852c';

@ProviderFor(appRouter)
final appRouterProvider = AutoDisposeProvider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')

typedef AppRouterRef = AutoDisposeProviderRef<GoRouter>;



