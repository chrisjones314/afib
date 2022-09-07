

import 'package:afib/src/dart/command/af_source_template.dart';

class AFExtendAppT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_path]/app.dart';
import 'package:[!af_package_path]/initialization/[!af_app_namespace]_define_core.dart';
import 'package:[!af_package_path]/query/startup_query.dart';

void installCoreApp(AFAppExtensionContext context) {

    context.installCoreApp(
      defineCore: defineCore,
      defineFundamentalTheme: defineFundamentalTheme, 
      createStartupQuery: () => StartupQuery(),
      createApp: () => [!af_app_namespace(upper)]App(),
    );

}
''';
}
