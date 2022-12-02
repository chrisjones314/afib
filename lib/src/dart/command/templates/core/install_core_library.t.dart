 

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class InstallCoreLibraryT extends AFFileSourceTemplate {
  final bool defineFundamentalTheme;
  InstallCoreLibraryT({
    required this.defineFundamentalTheme,
    required List<String> templatePath,
  }): super(
    templatePath: templatePath,
  );


  String get template {
    final defineFundamentalThemeText = defineFundamentalTheme ? "defineFundamentalTheme: defineFundamentalTheme," : "";
    return '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/initialization/${insertAppNamespace}_define_core.dart';

void installCoreLibrary(AFCoreLibraryExtensionContext context) {
    context.installCoreLibrary(
      defineCore: defineCore,
      $defineFundamentalThemeText
    );
}
''';
  }
}

class InstallUILibraryT extends InstallCoreLibraryT {
  InstallUILibraryT(): super(
    defineFundamentalTheme: true,
    templatePath: const <String>[AFProjectPaths.folderCore, "install_ui_library"],
  );
}

class InstallStateLibraryT extends InstallCoreLibraryT {
  InstallStateLibraryT(): super(
    defineFundamentalTheme: false,
    templatePath: const <String>[AFProjectPaths.folderCore, "install_state_library"],
  );
}