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
  static const argForceOverwrite = "force-overwrite";
  static const argExportTemplatesHelpStatic = "$argOverrideTemplatesFlag - A comma separated list of assignments (.e.g x=y) with the template path on the right overriding that on the left (e.g 'core/query_simple=examples/query_write_count,...')";
  static const argForceOverwriteHelpStatic = "$argForceOverwrite - specify if you'd like the command to overwrite existing files";
  static const argMemberVariables = "member-variables";
  static const argResolveVariables = "resolve-variables";
  static const argMemberVariablesHelp = "--$argMemberVariables - A semi-colon separated list of member variables, which are automatically carried through to copyWith, etc.";
  static const argResolveVariablesHelp = "--$argResolveVariables - A semi-colon separated list of member variables, of the form 'ModelType variable;...' which is actually represented as a String id and a resolve method";


  String get argExportTemplates => argExportTemplatesFlag;
  String get argExportTemplatesHelp => "$argExportTemplatesFlag - Generate modifiable template files in the generate folder instead of executing the actual generation.";
  String get argOverrideTemplates => argOverrideTemplatesFlag;
  String get argOverrideTemplatesHelp => argExportTemplatesHelpStatic;
  String get argForceOverwriteHelp => argForceOverwriteHelpStatic;


  

}

