



import 'package:afib/src/dart/command/af_source_template.dart';

class AFMainT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/initialization/create_dart_params.dart';
import 'package:[!af_package_path]/initialization/extend/extend_app.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base_library.dart';
import 'package:[!af_package_path]/initialization/extend/extend_test.dart';
import 'package:[!af_package_path]/initialization/extend/extend_ui_library.dart';
import 'package:[!af_package_path]/state/[!af_app_namespace]_state.dart';

void main() {  
  afMainWrapper(() {
    final paramsDart = createDartParams();
    afMainApp<[!af_app_namespace(upper)]State>(
      paramsDart: paramsDart, 
      extendBase: extendBase, 
      extendBaseLibrary: extendBaseLibrary, 
      extendApp: extendApp, 
      extendUILibrary: extendUILibrary, 
      extendTest: extendTest
    );
  });
}''';

}




