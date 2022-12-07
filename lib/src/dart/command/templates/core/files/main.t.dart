import 'package:afib/src/dart/command/af_source_template.dart';

class MainT extends AFCoreFileSourceTemplate {

  MainT(): super(
    templateFileId: "main",
  );  

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/initialization/create_dart_params.dart';
import 'package:$insertPackagePath/initialization/install/install_core_app.dart';
import 'package:$insertPackagePath/initialization/install/install_base.dart';
import 'package:$insertPackagePath/initialization/install/install_base_library.dart';
import 'package:$insertPackagePath/initialization/install/install_test.dart';

void main() {  
  afMainWrapper(() {
    final paramsDart = createDartParams();
    afMainApp(
      paramsDart: paramsDart, 
      installBase: installBase, 
      installBaseLibrary: installBaseLibrary, 
      installCoreApp: installCoreApp, 
      installCoreLibrary: installCoreLibrary, 
      installTest: installTest
    );
  });
}''';

}





