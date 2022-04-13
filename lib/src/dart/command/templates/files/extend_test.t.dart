
import 'package:afib/src/dart/command/af_source_template.dart';

class AFExtendTestT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/test/ui_prototypes.dart';
import 'package:[!af_package_path]/test/state_tests.dart';
import 'package:[!af_package_path]/test/test_data.dart';
import 'package:[!af_package_path]/test/unit_tests.dart';
import 'package:[!af_package_path]/test/wireframes.dart';

void extendTest(AFTestExtensionContext extend) {

    extend.initializeTestFundamentals(
      defineTestData: defineTestData,
      defineUnitTests: defineUnitTests,
      defineStateTests: defineStateTests,
      defineScreenTests: defineUIPrototypes,
      defineWireframes: defineWireframes,
    );

    // you can register custom applicators that make it simpler to interact
    // with commonly used widgets in test code.
    // extend.registerApplicator(ApplySpeedDialTapAction());
}
''';
}
