

import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareSPIT extends AFSourceTemplate {
  final String template = '''

[!af_comment_spi_intro]
@immutable
class [!af_screen_name]SPI extends [!af_spi_parent_type]<[!af_state_view_type], [!af_screen_name]RouteParam> {
  [!af_screen_name]SPI(AFBuildContext<[!af_state_view_type], [!af_screen_name]RouteParam> context, AFScreenID screenId, [!af_theme_type] theme): super(context, screenId, theme, );
  
  factory [!af_screen_name]SPI.create(AFBuildContext<[!af_state_view_type], [!af_screen_name]RouteParam> context, [!af_theme_type] theme, AFScreenID screenId, ) {
    return [!af_screen_name]SPI(context, screenId, theme,
    );
  }

  [!af_spi_impls]
  
}
''';
}