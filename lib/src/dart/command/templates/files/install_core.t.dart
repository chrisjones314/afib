

import 'package:afib/src/dart/command/af_source_template.dart';

class AFInstallCoreT extends AFSourceTemplate {
  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
[!af_include_install_tests]

void [!af_app_namespace]InstallCore(AFAppLibraryExtensionContext context) {
  final libContext = context.register(
    [!af_app_namespace(upper)]LibraryID.id
  );
  installCoreLibrary(libContext);
  [!af_call_install_tests]
}
''';
}
