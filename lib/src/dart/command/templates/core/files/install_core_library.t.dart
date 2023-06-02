import 'package:afib/src/dart/command/af_source_template.dart';

/// Any class that ends in "T" is a source template used in code generation.
class InstallCoreLibraryT extends AFCoreFileSourceTemplate {
  final bool defineFundamentalTheme;
  InstallCoreLibraryT({
    required this.defineFundamentalTheme,
    required String templateFileId,
  }): super(
    templateFileId: templateFileId,
  );


  @override
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

/// Any class that ends in "T" is a source template used in code generation.
class InstallUILibraryT extends InstallCoreLibraryT {
  InstallUILibraryT(): super(
    defineFundamentalTheme: true,
    templateFileId: "install_ui_library",
  );
}

/// Any class that ends in "T" is a source template used in code generation.
class InstallStateLibraryT extends InstallCoreLibraryT {
  InstallStateLibraryT(): super(
    defineFundamentalTheme: false,
    templateFileId: "install_state_library",
  );
}