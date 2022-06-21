

import 'package:afib/src/dart/command/af_source_template.dart';

class AFInstallUIT extends AFSourceTemplate {
  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/initialization/install/install_app.dart';
import 'package:[!af_package_path]/initialization/install/install_test.dart';

void [!af_app_namespace]ExtendUI(AFAppLibraryExtensionContext extend) {
  AFUILibraryExtensionContext libContext = extend.register(
    [!af_app_namespace(upper)]LibraryID.id
  );
  extendUI(libContext);
  extendTest(libContext.test);
}
''';
}
