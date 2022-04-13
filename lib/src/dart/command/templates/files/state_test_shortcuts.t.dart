import 'package:afib/src/dart/command/af_source_template.dart';

class AFStateTestShortcutsT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';

class [!af_app_namespace(upper)]StateTestShortcuts {
  final AFSpecificStateTestDefinitionContext testContext;
  [!af_app_namespace(upper)]StateTestShortcuts(this.testContext);
}
''';

}
