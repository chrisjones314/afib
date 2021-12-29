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
  final AFInitConfigurationDelegate initAfib;
  final AFInitConfigurationDelegate initAppConfig;
  final AFInitConfigurationDelegate initDebugConfig;
  final AFInitConfigurationDelegate initProductionConfig;
  final AFInitConfigurationDelegate initPrototypeConfig;
  final AFInitConfigurationDelegate initTestConfig;
  final Logger? logger;
  final AFEnvironment? forceEnv;
   
  
  AFDartParams({
    required this.initAfib,
    required this.initAppConfig,
    required this.initDebugConfig,
    required this.initProductionConfig,
    required this.initPrototypeConfig,
    required this.initTestConfig,
    this.logger,
    this.forceEnv
  });

  AFDartParams forceEnvironment(AFEnvironment env) {
    return copyWith(forceEnv: env);
  }

  static AFDartParams createEmpty() {
    return AFDartParams(
      initAfib: nullConfigFunction,
      initAppConfig: nullConfigFunction,
      initDebugConfig: nullConfigFunction,
      initProductionConfig: nullConfigFunction,
      initPrototypeConfig: nullConfigFunction,
      initTestConfig: nullConfigFunction,
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
