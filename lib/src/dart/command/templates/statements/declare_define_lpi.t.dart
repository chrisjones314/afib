import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareDefineLPIT extends AFSourceTemplate {
  final String template = '  context.defineLPI([!af_lpi_id], createLPI: [!af_lpi_type].create);';
}

