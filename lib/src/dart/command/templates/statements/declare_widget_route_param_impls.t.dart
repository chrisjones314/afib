import 'package:afib/src/dart/command/af_source_template.dart';

class DeclareWidgetRouteParamImplsT extends AFSourceTemplate {
  final String template = '''
  [!af_screen_name]RouteParam({
    required AFScreenID screenId,
    required AFWidgetID wid
  }): super(screenId: screenId, wid: wid);

  factory [!af_screen_name]RouteParam.create({
    required AFScreenID screenId,
    required AFWidgetID wid,
  }) {
    return [!af_screen_name]RouteParam(
      screenId: screenId,
      wid: wid,
    );
  }

  [!af_screen_name]RouteParam copyWith() {
    return [!af_screen_name]RouteParam(
      screenId: screenId,
      wid: wid,
    );
  }
''';  
}
