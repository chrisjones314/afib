
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_create_screen_prototype.t.dart';

class SnippetDrawerExtraConfigParamsT extends AFCoreSnippetSourceTemplate {

  const SnippetDrawerExtraConfigParamsT();

  String get template => '''createDefaultRouteParam: (ref, state) => ${AFSourceTemplate.insertMainTypeInsertion}RouteParam.create(${SnippetCreateScreenPrototypeT.insertNavigatePushParams}),''';

}
