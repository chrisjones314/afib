import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class MainAFibTestT extends AFCoreFileSourceTemplate {
  static const insertInstallAppParam = AFSourceTemplateInsertion("install_app_param");

  MainAFibTestT(): super(
    templateFileId: "main_afib_test",
  );  

  @override
  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';
import 'package:$insertPackagePath/initialization/create_dart_params.dart';
import 'package:$insertPackagePath/initialization/install/install_base.dart';
import 'package:$insertPackagePath/initialization/install/install_base_library.dart';
import 'package:$insertPackagePath/initialization/install/install_test.dart';
import 'package:$insertPackagePath/initialization/install/install_core_library.dart';
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
          await afTestMain$insertLibKind(
            id: ${insertAppNamespaceUpper}LibraryID.id,
            paramsDart: paramsDart,
            installBase: installBase, 
            installBaseLibrary: installBaseLibrary, 
            $insertInstallAppParam    
            installTest: installTest,
            widgetTester: tester
          );
        });
      });
  });
}
''';

}







