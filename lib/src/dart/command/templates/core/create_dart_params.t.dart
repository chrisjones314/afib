
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class CreateDartParamsT extends AFFileSourceTemplate {

  CreateDartParamsT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "create_dart_params"],
  );  

  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:$insertPackagePath/initialization/application.dart';
import 'package:$insertPackagePath/initialization/${insertAppNamespace}_config.g.dart';
import 'package:$insertPackagePath/initialization/environments/debug.dart';
import 'package:$insertPackagePath/initialization/environments/production.dart';
import 'package:$insertPackagePath/initialization/environments/prototype.dart';
import 'package:$insertPackagePath/initialization/environments/test.dart';

AFDartParams createDartParams() {
  return AFDartParams(    
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



