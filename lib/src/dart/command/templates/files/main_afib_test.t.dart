



import 'package:afib/src/dart/command/af_source_template.dart';

class AFMainAFibTestT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/initialization/create_dart_params.dart';
import 'package:[!af_package_path]/initialization/extend/extend_app.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_third_party_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_test.dart';
import 'package:[!af_package_path]/initialization/extend/extend_third_party_ui.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';
import 'package:flutter_test/flutter_test.dart';

//------------------------------------------------------------------------------
void main() async {
  afTestMainStartup();

  group("AFib Test", () {
    testWidgets('Afib Test', (tester) async {
      final paramsD = createDartParams();
      await afTestWidgetStartup(paramsD, tester, () async {

          // If you are trying to debug a specific test, select that specific test by running
          // it from the command line  using (bin/afib.dart test [your_test_id]).  
          // This will set the AFibConfigEntries.enabledTestList value appropriately in afib.g.dart.  When you
          // debug this function, just that test will be executed.
          await afTestMain<[!af_app_namespace(upper)]State>(
            paramsD: paramsD,
            extendBase: extendBase, 
            extendApp: extendApp, 
            extendThirdPartyBase: extendThirdPartyBase, 
            extendThirdPartyUI: extendThirdPartyUI, 
            extendTest: extendTest,
            widgetTester: tester
          );
        });
      });
  });
}
''';

}







