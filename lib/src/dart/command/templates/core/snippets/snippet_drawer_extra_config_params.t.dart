
import 'package:afib/afib_command.dart';
import 'package:afib/src/dart/command/templates/core/snippets/snippet_create_screen_prototype.t.dart';

/// Any class that ends in "T" is a source template used in code generation.
class SnippetDrawerExtraConfigParamsT extends AFCoreSnippetSourceTemplate {

  const SnippetDrawerExtraConfigParamsT();

  @override
  String get template => '''createDefaultRouteParam: (ref, state) => ${AFSourceTemplate.insertMainTypeInsertion}RouteParam.create(${SnippetCreateScreenPrototypeT.insertNavigatePushParams}),''';

}
