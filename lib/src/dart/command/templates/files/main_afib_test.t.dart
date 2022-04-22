



import 'package:afib/src/dart/command/af_source_template.dart';

class AFMainAFibTestT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/initialization/create_dart_params.dart';
import 'package:[!af_package_path]/initialization/extend/extend_app.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base_library.dart';
import 'package:[!af_package_path]/initialization/extend/extend_test.dart';
import 'package:[!af_package_path]/initialization/extend/extend_ui_library.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';
import 'package:flutter_test/flutter_test.dart';

//------------------------------------------------------------------------------
void main() async {
  afTestMainStartup();

  group("AFib Test", () {
    testWidgets('Afib Test', (tester) async {
      final paramsDart = createDartParams();
      await afTestWidgetStartup(paramsDart, tester, () async {

          // If you are trying to debug a specific test, select that specific test by running
          // it from the command line  using (bin/afib.dart test [your_test_id]).  
          // This will set the AFibConfigEntries.enabledTestList value appropriately in afib.g.dart.  When you
          // debug this function, just that test will be executed.
          await afTestMain[!af_lib_kind]<[!af_app_namespace(upper)]State>(
            id: [!af_app_namespace(upper)]LibraryID.id,
            paramsDart: paramsDart,
            extendBase: extendBase, 
            extendBaseLibrary: extendBaseLibrary, 
            [!af_extend_app_param],
            extendUILibrary: extendUILibrary, 
            extendTest: extendTest,
            widgetTester: tester
          );
        });
      });
  });
}
''';

}







