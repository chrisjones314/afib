import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

void nullConfigFunction(AFConfig config) {}

/// Application initialization parameters that do not depend on flutter.
/// 
/// It is important to keep flutter dependencies separate so this data
/// can still be used from command-line executables.
@immutable
class AFDartParams<AppState> {
  final AFInitConfigurationDelegate configureAfib;
  final AFInitConfigurationDelegate configureAppConfig;
  final AFInitConfigurationDelegate configureDebugConfig;
  final AFInitConfigurationDelegate configureProductionConfig;
  final AFInitConfigurationDelegate condfigurePrototypeConfig;
  final AFInitConfigurationDelegate configureTestConfig;
  final Logger? logger;
  final AFEnvironment? forceEnv;   
  
  AFDartParams({
    required this.configureAfib,
    required this.configureAppConfig,
    required this.configureDebugConfig,
    required this.configureProductionConfig,
    required this.condfigurePrototypeConfig,
    required this.configureTestConfig,
    this.logger,
    this.forceEnv
  });

  AFDartParams forceEnvironment(AFEnvironment env) {
    return copyWith(forceEnv: env);
  }

  static AFDartParams createEmpty() {
    return AFDartParams(
      configureAfib: nullConfigFunction,
      configureAppConfig: nullConfigFunction,
      configureDebugConfig: nullConfigFunction,
      configureProductionConfig: nullConfigFunction,
      condfigurePrototypeConfig: nullConfigFunction,
      configureTestConfig: nullConfigFunction,
    );
  }


  AFDartParams copyWith({
    AFInitConfigurationDelegate? initAfib,
    AFInitConfigurationDelegate? initAppConfig,
    AFInitConfigurationDelegate? initDebugConfig,
    AFInitConfigurationDelegate? initProductionConfig,
    AFInitConfigurationDelegate? initPrototypeConfig,
    AFInitConfigurationDelegate? initTestConfig,
    Logger? logger,
    AFEnvironment? forceEnv,
  }) {
    return AFDartParams(
      configureAfib: initAfib ?? this.configureAfib,
      configureAppConfig: initAppConfig ?? this.configureAppConfig,
      configureDebugConfig: initDebugConfig ?? this.configureDebugConfig,
      configureProductionConfig: initProductionConfig ?? this.configureProductionConfig,
      condfigurePrototypeConfig: initPrototypeConfig ?? this.condfigurePrototypeConfig,
      configureTestConfig: initTestConfig ?? this.configureTestConfig,
      logger: logger ?? this.logger,
      forceEnv: forceEnv ?? this.forceEnv
    );
  }
}
