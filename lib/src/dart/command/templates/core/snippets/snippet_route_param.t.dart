import 'package:afib/src/dart/command/af_source_template.dart';

class SnippetRouteParamT extends AFCoreSnippetSourceTemplate {
  final String template = '''
  [!af_screen_name]RouteParam({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,
  }): super(screenId: screenId, wid: wid, routeLocation: routeLocation);

  factory [!af_screen_name]RouteParam.create({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,
  }) {
    return [!af_screen_name]RouteParam(
      screenId: screenId,
      wid: wid,
      routeLocation: routeLocation,
    );
  }

  [!af_screen_name]RouteParam copyWith() {
    return [!af_screen_name]RouteParam(
      screenId: screenId,
      wid: wid,
      routeLocation: routeLocation,
    );
  }
''';  
}
