
import 'package:logging/logging.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:meta/meta.dart';

typedef void InitConfiguration(AFConfig config);

/// Application initialization parameters that do not depend on flutter.
/// 
/// It is important to keep flutter dependencies separate so this data
/// can still be used from command-line executables.
@immutable
class AFDartParams<AppState> {
  final InitConfiguration initAfib;
  final InitConfiguration initAppConfig;
  final InitConfiguration initDebugConfig;
  final InitConfiguration initProductionConfig;
  final InitConfiguration initPrototypeConfig;
  final InitConfiguration initTestConfig;
  final Logger logger;
  final String forceEnv;
   
  
  AFDartParams({
    @required this.initAfib,
    @required this.initAppConfig,
    @required this.initDebugConfig,
    @required this.initProductionConfig,
    @required this.initPrototypeConfig,
    @required this.initTestConfig,
    this.logger,
    this.forceEnv
  });

  AFDartParams forceEnvironment(String env) {
    return copyWith(forceEnv: env);
  }


  AFDartParams copyWith({
    InitConfiguration initAfib,
    InitConfiguration initAppConfig,
    InitConfiguration initDebugConfig,
    InitConfiguration initProductionConfig,
    InitConfiguration initPrototypeConfig,
    InitConfiguration initTestConfig,
    Logger logger,
    String forceEnv,
  }) {
    return AFDartParams(
      initAfib: initAfib ?? this.initAfib,
      initAppConfig: initAppConfig ?? this.initAppConfig,
      initDebugConfig: initDebugConfig ?? this.initDebugConfig,
      initProductionConfig: initProductionConfig ?? this.initProductionConfig,
      initPrototypeConfig: initPrototypeConfig ?? this.initPrototypeConfig,
      initTestConfig: initTestConfig ?? this.initTestConfig,
      logger: logger ?? this.logger,
      forceEnv: forceEnv ?? this.forceEnv
    );
  }
}
