
/// Used in Afib.g.dart to specify the environment to run under.
enum AFEnvironment {
  /// Used for production builds.
  production,

  /// Used for debug builds.
  debug,

  /// Used to start in prototype mode, which displays a list of all prototype screens
  /// and includes a drawer used to run tests against them.
  prototype,

  /// Used in command-line tests.
  test,
}
