import 'package:afib/src/dart/command/af_project_paths.dart';
import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';

class SnippetWidgetRouteParamT extends AFSnippetSourceTemplate {
  
  SnippetWidgetRouteParamT({
    required String templateFileId,
    required List<String> templateFolder,
    required AFSourceTemplateInsertions? embeddedInsertions,
  }): super(
    templateFileId: templateFileId,
    templateFolder: templateFolder,
    embeddedInsertions: embeddedInsertions
  );

  factory SnippetWidgetRouteParamT.core() {
    return SnippetWidgetRouteParamT(
      templateFileId: "widget_route_param",
      templateFolder: AFProjectPaths.pathGenerateCoreSnippets,
      embeddedInsertions: AFSourceTemplateInsertions(insertions: {})
    );
  }

  String get template => '''
class ${insertMainType}RouteParam extends AF${ScreenT.insertControlTypeSuffix}RouteParam {
  
  ${insertMainType}RouteParam({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,
  }): super(screenId: screenId, wid: wid, routeLocation: routeLocation);

  factory ${insertMainType}RouteParam.create({
    required AFScreenID screenId,
    required AFWidgetID wid,
    required AFRouteLocation routeLocation,
  }) {
    return ${insertMainType}RouteParam(
      screenId: screenId,
      wid: wid,
      routeLocation: routeLocation,
    );
  }

  ${insertMainType}RouteParam copyWith({
    AFScreenID? screenId,
    AFWidgetID? wid,
    AFRouteLocation? routeLocation,
  }) {
    return ${insertMainType}RouteParam(
      screenId: screenId ?? this.screenId,
      wid: wid ?? this.wid,
      routeLocation: routeLocation ?? this.routeLocation,
    );
  }
}
''';  
}
