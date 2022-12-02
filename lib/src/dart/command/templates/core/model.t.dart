

import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';

class ModelT extends AFFileSourceTemplate {
  static const insertModelName = AFSourceTemplateInsertion("model_name");
  
  ModelT(): super(
    templatePath: const <String>[AFProjectPaths.folderCore, "model"],
  );  


  final String template = '''
import 'package:meta/meta.dart';

@immutable
class $insertModelName {
  $insertModelName();

  $insertModelName copyWith() {
    return $insertModelName();
  }
}
''';
}
