import 'package:afib/src/dart/command/af_source_template.dart';

class AFExtendLibraryBaseT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_command.dart';

void extendBaseLibrary(AFBaseExtensionContext context) {
  // the earliest/most basic hook for extending afib, both the command and the app
  // can be used to create custom configuration entries.
}
''';
}


