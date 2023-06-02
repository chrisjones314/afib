import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/command.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetCallDefineCommandT extends AFCoreSnippetSourceTemplate {
  @override
  final String template = '    context.defineCommand(${CommandT.insertCommandName}());';
}
