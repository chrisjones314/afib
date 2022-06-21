

import 'package:afib/src/dart/command/af_source_template.dart';

class AFInstallCoreLibraryT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/initialization/[!af_app_namespace]_define_core.dart';

void installCoreLibrary(AFUILibraryExtensionContext extend) {
    extend.installCoreLibrary(
      defineCore: defineCore,
      defineFundamentalThemeArea: defineFundamentalThemeArea
    );
}
''';
}
