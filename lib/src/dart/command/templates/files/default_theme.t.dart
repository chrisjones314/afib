
import 'package:afib/src/dart/command/af_source_template.dart';

class AFDefaultThemeT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';
import 'package:[!af_package_name]/[!af_app_namespace]_id.dart';

class [!af_app_namespace(upper)]DefaultTheme extends AFFunctionalTheme {
  [!af_app_namespace(upper)]DefaultTheme(AFFundamentalThemeState fundamentals): super(fundamentals: fundamentals, id: [!af_app_namespace(upper)]ThemeID.defaultTheme);
}

void defineFunctionalThemes(AFFunctionalThemeDefinitionContext context) {
  context.initUnlessPresent([!af_app_namespace(upper)]ThemeID.defaultTheme, createTheme: (f) => [!af_app_namespace(upper)]DefaultTheme(f));
}
''';
}
