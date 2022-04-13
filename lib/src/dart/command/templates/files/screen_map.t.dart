

import 'package:afib/src/dart/command/af_source_template.dart';

class AFScreenMapT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/ui/screens/startup_screen.dart';

void defineScreenMap(AFScreenMap screens) {
  screens.registerStartupScreen([!af_app_namespace(upper)]ScreenID.startup, () => StartupScreenRouteParam.create());
}  
''';

}