import 'package:afib/src/dart/command/af_command_enums.dart';
import 'package:afib/src/dart/utils/af_config.dart';
import 'package:afib/src/dart/utils/af_typedefs_dart.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';

void _nullConfigFunction(AFConfig config) {}

/// Application initialization parameters that do not depend on flutter.
/// 
/// This data is available from both AFib's command-line commands and Flutter.
/// You cannot import any Flutter UI into this class.
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
  
  const AFDartParams({
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
    return const AFDartParams(
      configureAfib: _nullConfigFunction,
      configureAppConfig: _nullConfigFunction,
      configureDebugConfig: _nullConfigFunction,
      configureProductionConfig: _nullConfigFunction,
      condfigurePrototypeConfig: _nullConfigFunction,
      configureTestConfig: _nullConfigFunction,
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
