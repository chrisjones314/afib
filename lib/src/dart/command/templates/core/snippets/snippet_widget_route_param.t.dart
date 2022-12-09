import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetWidgetRouteParamT extends AFCoreSnippetSourceTemplate {
  
  String get template => '''
class ${insertMainType}RouteParam extends AF${ScreenT.insertControlTypeSuffix}RouteParam {
  
  ${insertMainType}RouteParam({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,
  }): super(screenId: screenId, wid: wid, routeLocation: routeLocation);

  factory${insertMainType}RouteParam.create({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,
  }) {
    return${insertMainType}RouteParam(
      screenId: screenId,
      wid: wid,
      routeLocation: routeLocation,
    );
  }

  ${insertMainType}RouteParam copyWith() {
    return${insertMainType}RouteParam(
      screenId: screenId,
      wid: wid,
      routeLocation: routeLocation,
    );
  }
}
''';  
}
