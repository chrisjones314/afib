



import 'package:afib/src/dart/command/af_source_template.dart';

class AFMainUILibraryT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/initialization/create_dart_params.dart';
import 'package:[!af_package_path]/initialization/install/install_app.dart';
import 'package:[!af_package_path]/initialization/install/install_base.dart';
import 'package:[!af_package_path]/initialization/install/install_base_library.dart';
import 'package:[!af_package_path]/initialization/install/install_test.dart';

/// This is used to run in prototype mode during library development, it isn't used by library clients.
void main() {  
  afMainWrapper(() {
    final paramsD = createDartParams();
    afMainUILibrary(
      id: [!af_app_namespace(upper)]LibraryID.id, 
      paramsDart: paramsD, 
      installBase: installBase, 
      installBaseLibrary: installBaseLibrary, 
      installUI: installUI, 
      installTest: installTest);
  });
}
''';

}

