import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class CreateDartParamsT extends AFCoreFileSourceTemplate {

  CreateDartParamsT(): super(
    templateFileId: "create_dart_params",
  );  

  @override
  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:$insertPackagePath/initialization/application.dart';
import 'package:$insertPackagePath/initialization/${insertAppNamespace}_config.g.dart';
import 'package:$insertPackagePath/initialization/environments/debug.dart';
import 'package:$insertPackagePath/initialization/environments/production.dart';
import 'package:$insertPackagePath/initialization/environments/prototype.dart';
import 'package:$insertPackagePath/initialization/environments/test.dart';

AFDartParams createDartParams() {
  return const AFDartParams(    
    configureAfib: configureAfib,
    configureAppConfig: configureApplication,
    configureProductionConfig: configureProduction,
    condfigurePrototypeConfig: configurePrototype,
    configureTestConfig: configureTest,
    configureDebugConfig: configureDebug,
  );
}
''';
}



