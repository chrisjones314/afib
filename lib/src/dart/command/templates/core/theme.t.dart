
import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class ThemeT extends AFFileSourceTemplate {

  ThemeT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "theme"],
  );  

  String get template => '''
import 'package:afib/afib_flutter.dart';

class $insertMainType extends $insertMainParentType {
  $insertMainType(AFThemeID id, AFFundamentalThemeState fundamentals, AFBuildContext context): super(id, fundamentals, context);

  factory $insertMainType.create(AFThemeID id, AFFundamentalThemeState fundamentals, AFBuildContext context) {
    return $insertMainType(id, fundamentals, context);
  }
}

''';
}
