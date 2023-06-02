import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class TestDataT extends AFCoreFileSourceTemplate {

  TestDataT(): super(
    templateFileId: "test_data",
  );  

  @override
  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';
import 'package:$insertPackagePath/state/${insertAppNamespace}_state.dart';

void defineTestData(AFDefineTestDataContext context) {
  defineStates(context);
}

void defineStates(AFDefineTestDataContext context) {
  final stateFullLogin = <Object>[

  ];

  context.define(${insertAppNamespaceUpper}TestDataID.${insertAppNamespace}StateFullLogin, ${insertAppNamespaceUpper}State.fromList(stateFullLogin));
}

''';

}

