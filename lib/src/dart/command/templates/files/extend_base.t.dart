



import 'package:afib/src/dart/command/af_source_template.dart';

class AFExtendBaseT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_command.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';

void extendBase(AFBaseExtensionContext context) {
  // the earliest/most basic hook for extending afib, both the command and the app
  // can be used to create custom configuration entries.
  context.registerLibrary([!af_app_namespace(upper)]LibraryID.id);
}
''';
}



