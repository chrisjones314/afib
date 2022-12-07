



import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class InstallBaseT extends AFCoreFileSourceTemplate {

  InstallBaseT(): super(
    templateFileId: "install_base",
  );

  String get template => '''
import 'package:afib/afib_command.dart';
import 'package:$insertPackageName/${insertAppNamespace}_id.dart';

void installBase(AFBaseExtensionContext context) {
  // the earliest/most basic hook for extending afib, both the command and the app
  // can be used to create custom configuration entries.
  context.registerLibrary(${insertAppNamespaceUpper}LibraryID.id);
}
''';
}



