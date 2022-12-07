import 'package:afib/src/dart/command/af_source_template.dart';

class InstallCoreAppT extends AFCoreFileSourceTemplate {

  InstallCoreAppT(): super(
    templateFileId: "install_core_app",
  );

  String get template => '''
import 'package:afib/afib_flutter.dart';
import 'package:$insertPackagePath/app.dart';
import 'package:$insertPackagePath/initialization/${insertAppNamespace}_define_core.dart';
import 'package:$insertPackagePath/query/simple/startup_query.dart';

void installCoreApp(AFAppExtensionContext context) {

    context.installCoreApp(
      defineCore: defineCore,
      defineFundamentalTheme: defineFundamentalTheme, 
      createStartupQuery: () => StartupQuery(),
      createApp: () => ${insertAppNamespaceUpper}App(),
    );

}
''';
}
