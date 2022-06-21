

import 'package:afib/src/dart/command/af_source_template.dart';

class AFInstallCoreLibraryT extends AFSourceTemplate {
  final bool defineFundamentalTheme;
  AFInstallCoreLibraryT({
    required this.defineFundamentalTheme
  });


  String get template {
    final defineFundamentalThemeText = defineFundamentalTheme ? "defineFundamentalTheme: defineFundamentalTheme," : "";
    return '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/initialization/[!af_app_namespace]_define_core.dart';

void installCoreLibrary(AFCoreLibraryExtensionContext context) {
    context.installCoreLibrary(
      defineCore: defineCore,
      $defineFundamentalThemeText
    );
}
''';
  }
}

class AFInstallUILibraryT extends AFInstallCoreLibraryT {
  AFInstallUILibraryT(): super(defineFundamentalTheme: true);
}

class AFInstallStateLibraryT extends AFInstallCoreLibraryT {
  AFInstallStateLibraryT(): super(defineFundamentalTheme: false);
}