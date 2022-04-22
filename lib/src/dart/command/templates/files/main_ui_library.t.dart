



import 'package:afib/src/dart/command/af_source_template.dart';

class AFMainUILibraryT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/initialization/create_dart_params.dart';
import 'package:[!af_package_path]/initialization/extend/extend_app.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base_library.dart';
import 'package:[!af_package_path]/initialization/extend/extend_test.dart';

/// This is used to run in prototype mode during library development, it isn't used by library clients.
void main() {  
  afMainWrapper(() {
    final paramsD = createDartParams();
    afMainUILibrary<AFComponentStateUnused>(
      id: [!af_app_namespace(upper)]LibraryID.id, 
      paramsDart: paramsD, 
      extendBase: extendBase, 
      extendBaseLibrary: extendBaseLibrary, 
      extendUI: extendUI, 
      extendTest: extendTest);
  });
}
''';

}

