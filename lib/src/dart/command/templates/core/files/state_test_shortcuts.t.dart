import 'package:afib/src/dart/command/af_source_template.dart';

class StateTestShortcutsT extends AFCoreFileSourceTemplate {

  StateTestShortcutsT(): super(
    templateFileId: "state_test_shortcuts",
  );

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';

class ${insertAppNamespaceUpper}StateTestShortcuts {
  final AFSpecificStateTestDefinitionContext testContext;
  ${insertAppNamespaceUpper}StateTestShortcuts(this.testContext);
}
''';

}
