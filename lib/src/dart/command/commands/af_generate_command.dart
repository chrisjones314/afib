import 'package:afib/src/dart/command/af_command.dart';


class AFGenerateParentCommand extends AFCommandGroup {
  final name = "generate";
  final description = "Generate AFib source code for screens, queries, models, and more";
  

  @override
  Future<void> execute(AFCommandContext ctx) async {

  }
}


abstract class AFGenerateSubcommand extends AFCommand {
  static const argExportTemplatesFlag = "export-templates";
  static const argOverrideTemplatesFlag = "override-templates";
  static const argExportTemplatesHelpStatic = "$argOverrideTemplatesFlag - A comma separated list of assignments (.e.g x=y) with the template path on the right overriding that on the left (e.g 'core/query_simple=examples/query_write_count,...')";

  String get argExportTemplates => argExportTemplatesFlag;
  String get argExportTemplatesHelp => "$argExportTemplatesFlag - Generate modifiable template files in the generate folder instead of executing the actual generation.";
  String get argOverrideTemplates => argOverrideTemplatesFlag;
  String get argOverrideTemplatesHelp => argExportTemplatesHelpStatic;

}

