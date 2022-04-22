


import 'package:afib/src/dart/command/af_source_template.dart';

class AFInstallCommandT extends AFSourceTemplate {
  final String template = '''
import 'package:afib/afib_command.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';
import 'package:[!af_package_path]/initialization/extend/extend_base.dart';
import 'package:[!af_package_path]/initialization/extend/extend_command.dart';

void [!af_app_namespace]ExtendCommand(AFCommandUILibraryExtensionContext definitions) {
  extendCommand(definitions);
}

void [!af_app_namespace]ExtendBase(AFBaseExtensionContext context) {
  context.registerLibrary([!af_app_namespace(upper)]LibraryID.id);
  extendBase(context);
}
''';
}
