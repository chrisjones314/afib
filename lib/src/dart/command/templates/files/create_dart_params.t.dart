
import 'package:afib/src/dart/command/af_source_template.dart';

class AFCreateDartParamsT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_command.dart';
import 'package:[!af_package_path]/initialization/application.dart';
import 'package:[!af_package_path]/initialization/[!af_app_namespace]_config.g.dart';
import 'package:[!af_package_path]/initialization/environments/debug.dart';
import 'package:[!af_package_path]/initialization/environments/production.dart';
import 'package:[!af_package_path]/initialization/environments/prototype.dart';
import 'package:[!af_package_path]/initialization/environments/test.dart';

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



