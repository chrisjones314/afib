

import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareWidgetSPIT extends AFSourceTemplate {
  final String template = '''
@immutable
class [!af_screen_name]SPI extends [!af_spi_parent_type]<[!af_state_view_type], [!af_screen_name]RouteParam> {
  [!af_screen_name]SPI(AFBuildContext<[!af_state_view_type], [!af_screen_name]RouteParam> context, AFScreenID screenId, AFID wid, AFWidgetParamSource paramSource, [!af_theme_type] theme): super(context, screenId, wid, paramSource, theme);

  factory [!af_screen_name]SPI.create(AFBuildContext<[!af_state_view_type], [!af_screen_name]RouteParam> context, [!af_theme_type] theme, AFScreenID screenId, AFID wid, AFWidgetParamSource paramSource) {
    return [!af_screen_name]SPI(context, screenId, wid, paramSource, theme);
  }  

}
''';
}
