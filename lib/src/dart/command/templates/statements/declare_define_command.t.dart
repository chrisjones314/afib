import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDefineCommandT extends AFSourceTemplate {
  final String template = '    context.defineCommand([!af_command_name]());';
}
