import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/commands/af_create_command.dart';

class StartHereT extends AFFileSourceTemplate {

  StartHereT(): super(
    templatePath: const <String>[AFProjectPaths.folderProjectStyles, AFCreateAppCommand.projectStyleStartHere],
  );

  String get template => '''
generate state CountHistoryRoot
generate query ReadCountInStateQuery --result-type CountHistoryRoot --override-templates "core/query_simple=example/count/query_read_count_in_state"
''';

}







