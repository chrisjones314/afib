


import 'package:afib/src/dart/command/af_source_template.dart';

class AFInstallCommandT extends AFSourceTemplate {
  final String template = '''
import 'package:afib/afib_command.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/initialization/install/install_base.dart';
import 'package:[!af_package_path]/initialization/install/install_command.dart';

void [!af_app_namespace]InstallCommand(AFCommandUILibraryExtensionContext definitions) {
  extendCommand(definitions);
}

void [!af_app_namespace]InstallBase(AFBaseExtensionContext context) {
  context.registerLibrary([!af_app_namespace(upper)]LibraryID.id);
  extendBase(context);
}
''';
}
