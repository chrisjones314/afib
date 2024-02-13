import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class MainUILibraryT extends AFCoreFileSourceTemplate {

  MainUILibraryT(): super(
    templateFileId: "main_ui_library",
  );  

  @override
  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';
import 'package:$insertPackagePath/initialization/create_dart_params.dart';
import 'package:$insertPackagePath/initialization/install/install_app.dart';
import 'package:$insertPackagePath/initialization/install/install_base.dart';
import 'package:$insertPackagePath/initialization/install/install_base_library.dart';
import 'package:$insertPackagePath/initialization/install/install_test.dart';

/// This is used to run in prototype mode during library development, it isn't used by library clients.
void main() {  
  afMainWrapper((widgetBinding) {
    final paramsD = createDartParams();
    afMainUILibrary(
      id: ${insertAppNamespaceUpper}LibraryID.id, 
      paramsDart: paramsD, 
      installBase: installBase, 
      installBaseLibrary: installBaseLibrary, 
      installUI: installUI, 
      installTest: installTest);
  });
}
''';

}

