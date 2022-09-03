

import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareSPIT extends AFSourceTemplate {
  final String template = '''

@immutable
class [!af_screen_name]SPI extends [!af_spi_parent_type]<[!af_state_view_type], [!af_screen_name]RouteParam> {
  [!af_screen_name]SPI(AFBuildContext<[!af_state_view_type], [!af_screen_name]RouteParam> context, AFStandardSPIData standard): super(context, standard);
  
  factory [!af_screen_name]SPI.create(AFBuildContext<[!af_state_view_type], [!af_screen_name]RouteParam> context, AFStandardSPIData standard) {
    return [!af_screen_name]SPI(context, standard,
    );
  }

  [!af_spi_impls]
  
}
''';
}