import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class StateTestShortcutsT extends AFCoreFileSourceTemplate {

  StateTestShortcutsT(): super(
    templateFileId: "state_test_shortcuts",
  );

  @override
  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';

class ${insertAppNamespaceUpper}StateTestShortcuts {
  final AFSpecificStateTestDefinitionContext testContext;
  ${insertAppNamespaceUpper}StateTestShortcuts(this.testContext);
}
''';

}
