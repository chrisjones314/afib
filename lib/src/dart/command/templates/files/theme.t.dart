
import 'package:afib/src/dart/command/af_source_template.dart';

class AFThemeT extends AFSourceTemplate {

  final String template = '''
import 'package:afib/afib_flutter.dart';

class [!af_theme_type] extends [!af_parent_theme_type] {
  [!af_theme_type](AFThemeID id, AFFundamentalThemeState fundamentals, AFBuildContext context): super(id, fundamentals, context);

  factory [!af_theme_type].create(AFThemeID id, AFFundamentalThemeState fundamentals, AFBuildContext context) {
    return [!af_theme_type](id, fundamentals, context);
  }
}

''';
}
