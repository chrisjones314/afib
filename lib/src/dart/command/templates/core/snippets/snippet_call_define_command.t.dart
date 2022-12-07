import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/command.t.dart';

class SnippetCallDefineCommandT extends AFCoreSnippetSourceTemplate {
  final String template = '    context.defineCommand(${CommandT.insertCommandName}());';
}
