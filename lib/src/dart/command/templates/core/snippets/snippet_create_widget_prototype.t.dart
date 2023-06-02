import 'package:afib/src/dart/command/af_source_template.dart';
import 'package:afib/src/dart/command/templates/core/files/screen.t.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_create_screen_prototype.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetCreateWidgetPrototypeT extends AFSourceTemplate {
  String get template => '''
  var prototype = context.define${ScreenT.insertControlTypeSuffix}Prototype(
    id: ${insertAppNamespaceUpper}PrototypeID.${ScreenT.insertScreenID},
    stateView: ${insertAppNamespaceUpper}TestDataID.${SnippetCreateScreenPrototypeT.insertFullTestDataID},
    createLaunchParam: (screenId, wid, routeLocation) => ${insertMainType}RouteParam.create(screenId: screenId, wid: wid, routeLocation: routeLocation),
    render: (launchParam) {
      return $insertMainType(
        launchParam: launchParam
      );
    },
  );
  ''';
}

