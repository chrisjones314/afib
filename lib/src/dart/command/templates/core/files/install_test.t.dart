import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class InstallTestT extends AFCoreFileSourceTemplate {

  InstallTestT(): super(
    templateFileId: "install_test",
  );  


  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/test/ui_prototypes.dart';
import 'package:$insertPackagePath/test/state_tests.dart';
import 'package:$insertPackagePath/test/test_data.dart';
import 'package:$insertPackagePath/test/unit_tests.dart';
import 'package:$insertPackagePath/test/wireframes.dart';

void installTest(AFTestExtensionContext context) {

    context.installTests(
      defineTestData: defineTestData,
      defineUnitTests: defineUnitTests,
      defineStateTests: defineStateTests,
      defineUIPrototypes: defineUIPrototypes,
      defineWireframes: defineWireframes,
    );

    // you can register custom applicators that make it simpler to interact
    // with commonly used widgets in test code.
    // context.registerApplicator(ApplySpeedDialTapAction());
}
''';
}
